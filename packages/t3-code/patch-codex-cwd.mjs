// Give Codex's launcher the thread cwd so the configured direnv wrapper works.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";

const asar = createRequire(import.meta.url)(process.argv[2]);
const archive = join(process.argv[3], "app.asar");
const work = mkdtempSync(join(tmpdir(), "t3-cwd-"));
const stage = join(work, "app");
const packed = join(work, "app.asar");
const files = (archive) => asar.listPackage(archive).map((path) => path.slice(1)).sort();
const unpackedFiles = (archive) => files(archive).filter((path) => {
  const entry = asar.statFile(archive, path);
  return entry.unpacked && !entry.files;
});
const unpacked = unpackedFiles(archive);

const before = `\t\tconst command = yield* makeCodexAppServerSpawnCommand({
\t\t\tcommand: input.settings.binaryPath || "codex",
\t\t\targs: codexAppServerArgs(resolveCodexLaunchArgs(input.settings.launchArgs, input.environment)),
\t\t\tenv: environment,
\t\t\tthreadId: input.threadId
\t\t}).pipe(provideService(AgentScope, agentScope));`;
const after = before.replace(
  "\t\t\tenv: environment,",
  "\t\t\t...(input.runtimePolicy.cwd == null ? {} : { cwd: input.runtimePolicy.cwd }),\n\t\t\tenv: environment,",
);

asar.extractAll(archive, stage);
const matches = files(archive)
  .filter((path) => /^apps\/server\/dist\/binCli-.*\.mjs$/.test(path))
  .filter((path) => readFileSync(join(stage, path), "utf8").includes(before));
assert.equal(matches.length, 1, "Codex launch call changed; review this T3 release.");
const [target] = matches;
const source = readFileSync(join(stage, target), "utf8");
assert.equal(source.split(before).length, 2, "Codex launch call must be unique.");
writeFileSync(join(stage, target), source.replace(before, after));
execFileSync(process.execPath, ["--check", join(stage, target)], { stdio: "inherit" });

// Keep native libraries outside ASAR, exactly as upstream packaged them.
assert(unpacked.length && unpacked.every((path) => !/[{},*?[\]]/.test(path)));
await asar.createPackageWithOptions(stage, packed, {
  unpack: `{${unpacked.map((path) => `**/${path}`).join(",")}}`,
});
assert.deepEqual(files(packed), files(archive), "Archive paths changed.");
assert.deepEqual(unpackedFiles(packed), unpacked, "Unpacked layout changed.");
for (const path of files(archive)) {
  if (path !== target) {
    assert.deepEqual(asar.statFile(packed, path).integrity, asar.statFile(archive, path).integrity, path);
  }
}
for (const path of unpacked) {
  assert.deepEqual(readFileSync(`${packed}.unpacked/${path}`), readFileSync(`${archive}.unpacked/${path}`), path);
}
copyFileSync(packed, archive);
console.log(`Patched ${target}; preserved ${unpacked.length} unpacked files.`);
