import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = resolve(import.meta.dirname, '..');
const tempRoot = resolve(tmpdir());
const temp = mkdtempSync(join(tempRoot, 'maitre-context-'));
const fake = join(temp, 'fake-opencode.ps1');
const script = join(root, 'tools', 'show_context.ps1');
function run(mode, exit = 0, command = fake) {
  const result = spawnSync('pwsh', ['-NoProfile', '-File', script, '-Mode', mode, '-OpenCodeCommand', command], {
    cwd: temp, encoding: 'utf8', timeout: 30000, env: { ...process.env, MAITRE_TEST_EXIT: String(exit) },
  });
  if (result.error) throw result.error;
  return result;
}
try {
  writeFileSync(fake, 'Write-Output ("ARGS=" + ($args -join "|"))\nexit ([int]$env:MAITRE_TEST_EXIT)\n');
  for (const [mode, expected] of [['Stats', 'stats|--models|--cost'], ['Sessions', 'session|list'], ['Paths', 'debug|paths|db']]) {
    const result = run(mode);
    assert.equal(result.status, 0, result.stderr + result.stdout);
    assert.ok(result.stdout.includes('ARGS=' + expected), mode);
    assert.ok(!/\d[\d., ]*\s*%/.test(result.stdout), 'aucun pourcentage inventé');
    console.log('OK commande native ' + mode);
  }
  assert.equal(run('Stats', 7).status, 7, 'propager échec CLI');
  console.log('OK erreur CLI propagée');
  assert.equal(run('Stats', 0, join(temp, 'missing-opencode')).status, 2, 'commande absente');
  console.log('OK CLI absent signalé');
} finally {
  if (!resolve(temp).startsWith(tempRoot + sep)) throw new Error('Unsafe temporary cleanup path');
  rmSync(temp, { recursive: true, force: true });
}
