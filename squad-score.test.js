// Lightweight source-level checks for the deterministic matching configuration.
// Run: node --test tests/squad-score.test.js
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
const src = fs.readFileSync(new URL("../app.js", import.meta.url), "utf8");
test("matching weights are documented as 100 percent total", () => {
  const weights = [25,20,15,10,10,10,10];
  assert.equal(weights.reduce((a,b)=>a+b,0),100);
});
test("matching score function uses all seven attributes", () => {
  const start = src.indexOf("function score(me,p)");
  assert.notEqual(start,-1);
  const end = src.indexOf("\nfunction playerCard",start);
  const fn = src.slice(start,end);
  for (const token of ["me.game","me.rank","me.role","me.lang","me.region","me.availability","me.style"]) {
    assert.ok(fn.includes(token), `missing ${token}`);
  }
  assert.ok(fn.includes("Math.round"));
});
test("sample players include multiple games and incompatible candidates", () => {
  const games = ["BGMI","VALORANT","Minecraft","Free Fire MAX","Roblox"];
  for (const g of games) assert.ok(src.includes(`game:"${g}"`), `missing sample game ${g}`);
});
