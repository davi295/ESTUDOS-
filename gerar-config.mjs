// Lê o .env e gera o config.js que o site carrega.
// Uso: node gerar-config.mjs
import { readFileSync, writeFileSync } from "node:fs";

const env = Object.fromEntries(
  readFileSync(new URL(".env", import.meta.url), "utf8")
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith("#") && l.includes("="))
    .map((l) => [l.slice(0, l.indexOf("=")).trim(), l.slice(l.indexOf("=") + 1).trim()])
);

for (const k of ["SUPABASE_URL", "SUPABASE_ANON_KEY"]) {
  if (!env[k] || env[k].includes("SEU-PROJETO") || env[k].startsWith("sua-chave")) {
    console.error(`Preencha ${k} no .env`);
    process.exit(1);
  }
}

writeFileSync(
  new URL("config.js", import.meta.url),
  `// Gerado por gerar-config.mjs a partir do .env. A chave anon é pública por design;\n// quem protege os dados são as regras RLS do supabase.sql.\nwindow.CONFIG = ${JSON.stringify(
    { SUPABASE_URL: env.SUPABASE_URL, SUPABASE_ANON_KEY: env.SUPABASE_ANON_KEY },
    null,
    2
  )};\n`
);
console.log("config.js gerado");
