// Patch T3's packaged app: give Codex the thread cwd, and add a Neovim "Open in" editor.
// Each edit is anchored on text that must occur exactly once, so a changed release fails the build.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";

const asar = createRequire(import.meta.url)(process.argv[2]);
const archive = join(process.argv[3], "app.asar");
const work = mkdtempSync(join(tmpdir(), "t3-patch-"));
const stage = join(work, "app");
const packed = join(work, "app.asar");
const files = (archive) => asar.listPackage(archive).map((path) => path.slice(1)).sort();
const unpackedFiles = (archive) => files(archive).filter((path) => {
  const entry = asar.statFile(archive, path);
  return entry.unpacked && !entry.files;
});
const archived = files(archive);
const unpacked = unpackedFiles(archive);

asar.extractAll(archive, stage);
const read = (path) => readFileSync(join(stage, path), "utf8");
const one = (what, paths) => {
  assert.equal(paths.length, 1, `${what}: expected one file, found ${paths.length}; review this T3 release.`);
  return paths[0];
};
const patched = new Set();
/** Replaces the single match of `anchor` (string or RegExp) in `path` with `replace(match)`. */
const edit = (path, anchor, replace) => {
  const source = read(path);
  const count = typeof anchor === "string"
    ? source.split(anchor).length - 1
    : (source.match(new RegExp(anchor, "g")) ?? []).length;
  assert.equal(count, 1, `${path}: ${anchor} matched ${count} times; review this T3 release.`);
  writeFileSync(join(stage, path), source.replace(anchor, replace));
  patched.add(path);
};

const server = one("Server bundle", archived.filter((path) => /^apps\/server\/dist\/binCli-[^/]+\.mjs$/.test(path)));
const assets = archived.filter((path) => /^apps\/server\/dist\/client\/assets\/[^/]+\.js$/.test(path));

// Give Codex's launcher the thread cwd so the configured direnv wrapper works.
const codexLaunch = `\t\tconst command = yield* makeCodexAppServerSpawnCommand({
\t\t\tcommand: input.settings.binaryPath || "codex",
\t\t\targs: codexAppServerArgs(resolveCodexLaunchArgs(input.settings.launchArgs, input.environment)),
\t\t\tenv: environment,
\t\t\tthreadId: input.threadId
\t\t}).pipe(provideService(AgentScope, agentScope));`;
edit(server, codexLaunch, (launch) => launch.replace(
  "\t\t\tenv: environment,",
  "\t\t\t...(input.runtimePolicy.cwd == null ? {} : { cwd: input.runtimePolicy.cwd }),\n\t\t\tenv: environment,",
));

// Add a Neovim editor that runs `t3-neovim` from PATH; the server and web client each bundle the editor list.
const neovim = JSON.stringify({ id: "neovim", label: "Neovim", commands: ["t3-neovim"], launchStyle: "goto" });
edit(server, '\t{\n\t\tid: "file-manager",', (entry) => `${neovim},\n${entry}`);
const fileManager = "{id:`file-manager`,label:`File Manager`,commands:null,launchStyle:`direct-path`}";
edit(one("Client editor list", assets.filter((path) => read(path).includes(fileManager))), fileManager, (entry) => `${neovim},${entry}`);

// Neovim's logo in flat colors (gradients would need unique SVG ids), built with the chunk's own JSX runtime.
const neovimIconPaths = [
  { fill: "#1384CF", d: "M0 155.57 155-1v728L0 572.24Z" },
  { fill: "#55963B", d: "M598.94 156.98 442-1l3.18 728L600 572.22Z" },
  { fill: "#66AC45", d: "M154.99 0 558 615.19 445.22 728 42 114.17Z" },
  { fill: "#000", fillOpacity: 0.13, d: "M155 283.83l-.21 24.17L31 124.71 42.46 113Z" },
];
const icons = one("Icons chunk", assets.filter((path) => /\/Icons-[^/]+\.js$/.test(path)));
const runtimes = new Set([...read(icons).matchAll(/\(0,([\w$]+)\.jsxs?\)\(`svg`/g)].map(([, runtime]) => runtime));
assert.equal(runtimes.size, 1, `${icons}: expected one JSX runtime, found ${[...runtimes]}; review this T3 release.`);
const [jsx] = runtimes;
const iconName = "$t3NeovimIcon";
const iconPaths = neovimIconPaths.map((path) => `(0,${jsx}.jsx)("path",${JSON.stringify(path)})`);
const icon = `${iconName}=e=>(0,${jsx}.jsxs)("svg",{...e,viewBox:"-64.5 -1 729 729",children:[${iconPaths}]})`;
edit(icons, "export{", (exports) => `var ${icon};${exports}${iconName},`);

// List Neovim after Zed in the "Open in" picker.
const zedOption = /\{Icon:[\w$]+,value:`zed`,kind:`brand`\}/;
const picker = one("Open-in picker", assets.filter((path) => zedOption.test(read(path))));
edit(picker, `}from"./${basename(icons)}"`, (from) => `,${iconName}${from}`);
edit(picker, zedOption, (option) => `${option},{Icon:${iconName},value:"neovim",kind:"brand"}`);

for (const path of patched) {
  execFileSync(process.execPath, ["--check", join(stage, path)], { stdio: "inherit" });
}

// Keep native libraries outside ASAR, exactly as upstream packaged them.
assert(unpacked.length && unpacked.every((path) => !/[{},*?[\]]/.test(path)));
await asar.createPackageWithOptions(stage, packed, {
  unpack: `{${unpacked.map((path) => `**/${path}`).join(",")}}`,
});
assert.deepEqual(files(packed), archived, "Archive paths changed.");
assert.deepEqual(unpackedFiles(packed), unpacked, "Unpacked layout changed.");
for (const path of archived) {
  if (!patched.has(path)) {
    assert.deepEqual(asar.statFile(packed, path).integrity, asar.statFile(archive, path).integrity, path);
  }
}
for (const path of unpacked) {
  assert.deepEqual(readFileSync(`${packed}.unpacked/${path}`), readFileSync(`${archive}.unpacked/${path}`), path);
}
copyFileSync(packed, archive);
console.log(`Patched ${[...patched].join(", ")}; preserved ${unpacked.length} unpacked files.`);
