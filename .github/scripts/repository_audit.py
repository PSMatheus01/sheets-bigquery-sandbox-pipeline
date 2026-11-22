#!/usr/bin/env python3
"""Auditoria local e automatizada do repositório.

Este script utiliza somente a biblioteca padrão do Python e verifica:

- estrutura obrigatória;
- JSON;
- CSV;
- links Markdown locais;
- padrões sensíveis;
- arquivos proibidos;
- exemplos de Apps Script;
- scripts SQL;
- licença;
- capa;
- consistência básica do README.

O script não acessa serviços externos, planilhas ou BigQuery.
"""

from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path
from typing import Iterable
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[2]

ERRORS: list[str] = []
WARNINGS: list[str] = []
PASSES: list[str] = []


REQUIRED_FILES = [
    ".gitattributes",
    ".gitignore",
    "CHANGELOG.md",
    "CONTRIBUTING.md",
    "LICENSE",
    "README.md",
    "SECURITY.md",
    "architecture/current-state.md",
    "architecture/data-flow.md",
    "architecture/experimental-pipeline.md",
    "architecture/state-machine.md",
    "docs/adaptation-guide.md",
    "docs/architecture.md",
    "docs/incidents-and-recovery.md",
    "docs/methodology.md",
    "docs/results.md",
    "docs/sandbox-and-billing.md",
    "docs/use-cases.md",
    "evidence/experimental-summary.json",
    "evidence/formula-baseline-summary.json",
    "evidence/performance-summary.json",
    "evidence/test-matrix.md",
    "examples/configurations/sandbox-config.example.json",
    "examples/expected-output/divergences-example.csv",
    "examples/expected-output/exceptions-example.csv",
    "examples/expected-output/indicators-example.csv",
    "examples/synthetic-data/README.md",
    "examples/synthetic-data/input-example.csv",
    "examples/synthetic-data/team-example.csv",
    "src/apps-script/auditor.example.gs",
    "src/apps-script/config.example.gs",
    "src/apps-script/detector.example.gs",
    "src/apps-script/orchestrator.example.gs",
    "src/apps-script/publisher.example.gs",
    "src/apps-script/utilities.example.gs",
    "src/sql/01_raw_example.sql",
    "src/sql/02_clean_example.sql",
    "src/sql/03_rules_example.sql",
    "src/sql/04_indicators_example.sql",
    "src/sql/05_exceptions_example.sql",
    "src/sql/06_audit_example.sql",
    "templates/implementation-checklist.md",
    "templates/incident-report.md",
    "templates/privacy-review.md",
    "templates/risk-assessment.md",
    "templates/test-plan.md",
    "assets/cover/repository-cover.png",
    ".github/scripts/repository_audit.py",
    ".github/workflows/repository-audit.yml",
]


REQUIRED_DIRECTORIES = [
    "architecture",
    "assets",
    "assets/cover",
    "docs",
    "evidence",
    "examples",
    "examples/configurations",
    "examples/expected-output",
    "examples/synthetic-data",
    "src",
    "src/apps-script",
    "src/sql",
    "templates",
    ".github",
    ".github/scripts",
    ".github/workflows",
]


EXPECTED_CSV_ROWS = {
    "examples/synthetic-data/input-example.csv": 24,
    "examples/synthetic-data/team-example.csv": 4,
    "examples/expected-output/indicators-example.csv": 1,
    "examples/expected-output/divergences-example.csv": 4,
    "examples/expected-output/exceptions-example.csv": 14,
}


EXPECTED_SQL_FILES = [
    "src/sql/01_raw_example.sql",
    "src/sql/02_clean_example.sql",
    "src/sql/03_rules_example.sql",
    "src/sql/04_indicators_example.sql",
    "src/sql/05_exceptions_example.sql",
    "src/sql/06_audit_example.sql",
]


EXPECTED_APPS_SCRIPT_FILES = [
    "src/apps-script/auditor.example.gs",
    "src/apps-script/config.example.gs",
    "src/apps-script/detector.example.gs",
    "src/apps-script/orchestrator.example.gs",
    "src/apps-script/publisher.example.gs",
    "src/apps-script/utilities.example.gs",
]


TEXT_EXTENSIONS = {
    ".md",
    ".txt",
    ".json",
    ".csv",
    ".sql",
    ".gs",
    ".js",
    ".html",
    ".css",
    ".yml",
    ".yaml",
    ".xml",
    ".properties",
    ".toml",
    ".py",
}


PROHIBITED_FILE_NAMES = {
    ".env",
    "credentials.json",
    "service-account.json",
    "service_account.json",
    "token.json",
    "secrets.json",
    "private.key",
    "private.pem",
    "id_rsa",
    "id_ed25519",
}


PROHIBITED_SUFFIXES = {
    ".log",
    ".bak",
    ".backup",
    ".dump",
    ".sql.gz",
    ".key",
    ".pem",
    ".p12",
    ".pfx",
}


SENSITIVE_PATTERNS = [
    (
        "chave privada",
        re.compile(
            r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----",
            re.IGNORECASE,
        ),
    ),
    (
        "token GitHub",
        re.compile(
            r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}\b",
            re.IGNORECASE,
        ),
    ),
    (
        "token GitHub de granularidade fina",
        re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b", re.IGNORECASE),
    ),
    (
        "chave de API Google",
        re.compile(r"\bAIza[0-9A-Za-z_-]{30,}\b"),
    ),
    (
        "URL de planilha Google",
        re.compile(
            r"https?://docs\.google\.com/spreadsheets/d/[A-Za-z0-9_-]+",
            re.IGNORECASE,
        ),
    ),
    (
        "URL publicada pelo Apps Script",
        re.compile(
            r"https?://script\.google\.com/macros/s/[A-Za-z0-9_-]+",
            re.IGNORECASE,
        ),
    ),
    (
        "credencial de conta de serviço",
        re.compile(
            r"""["']type["']\s*:\s*["']service_account["']""",
            re.IGNORECASE,
        ),
    ),
    (
        "chave privada em JSON",
        re.compile(
            r"""["']private_key["']\s*:\s*["'][^"']{20,}["']""",
            re.IGNORECASE,
        ),
    ),
    (
        "segredo de cliente",
        re.compile(
            r"""["']client_secret["']\s*[:=]\s*["'][^"']{8,}["']""",
            re.IGNORECASE,
        ),
    ),
]


MARKDOWN_LINK_PATTERN = re.compile(
    r"!?\[[^\]]*]\(([^)]+)\)",
    re.MULTILINE,
)


def add_error(message: str) -> None:
    ERRORS.append(message)


def add_warning(message: str) -> None:
    WARNINGS.append(message)


def add_pass(message: str) -> None:
    PASSES.append(message)


def relative(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return str(path)


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            return path.read_text(encoding="utf-8-sig")
        except UnicodeDecodeError as exc:
            add_error(f"Arquivo de texto sem UTF-8 válido: {relative(path)}: {exc}")
    except OSError as exc:
        add_error(f"Não foi possível ler {relative(path)}: {exc}")

    return ""


def iter_repository_files() -> Iterable[Path]:
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue

        relative_parts = path.relative_to(ROOT).parts

        if ".git" in relative_parts:
            continue

        if "__pycache__" in relative_parts:
            continue

        yield path


def audit_required_structure() -> None:
    missing_directories = [
        directory
        for directory in REQUIRED_DIRECTORIES
        if not (ROOT / directory).is_dir()
    ]

    missing_files = [
        file_name
        for file_name in REQUIRED_FILES
        if not (ROOT / file_name).is_file()
    ]

    for directory in missing_directories:
        add_error(f"Diretório obrigatório ausente: {directory}")

    for file_name in missing_files:
        add_error(f"Arquivo obrigatório ausente: {file_name}")

    if not missing_directories and not missing_files:
        add_pass("Estrutura obrigatória do repositório")


def audit_prohibited_files() -> None:
    findings: list[str] = []

    for path in iter_repository_files():
        name_lower = path.name.lower()
        relative_path = relative(path).lower()

        if name_lower in PROHIBITED_FILE_NAMES:
            findings.append(relative(path))
            continue

        if name_lower.startswith(".env.") and name_lower != ".env.example":
            findings.append(relative(path))
            continue

        if any(relative_path.endswith(suffix) for suffix in PROHIBITED_SUFFIXES):
            findings.append(relative(path))

    if findings:
        for finding in sorted(set(findings)):
            add_error(f"Arquivo potencialmente sensível ou temporário: {finding}")
    else:
        add_pass("Ausência de arquivos proibidos ou temporários")


def audit_json_files() -> None:
    json_files = sorted(ROOT.rglob("*.json"))

    if not json_files:
        add_error("Nenhum arquivo JSON encontrado")
        return

    valid_count = 0

    for path in json_files:
        if ".git" in path.parts:
            continue

        text = read_text(path)

        if not text.strip():
            add_error(f"JSON vazio: {relative(path)}")
            continue

        try:
            value = json.loads(text)
        except json.JSONDecodeError as exc:
            add_error(
                f"JSON inválido em {relative(path)} "
                f"(linha {exc.lineno}, coluna {exc.colno}): {exc.msg}"
            )
            continue

        if not isinstance(value, (dict, list)):
            add_warning(
                f"JSON possui valor raiz incomum em {relative(path)}: "
                f"{type(value).__name__}"
            )

        valid_count += 1

    if valid_count == len(json_files):
        add_pass(f"Validação de JSON ({valid_count} arquivo(s))")


def audit_csv_files() -> None:
    csv_files = sorted(ROOT.rglob("*.csv"))

    if not csv_files:
        add_error("Nenhum arquivo CSV encontrado")
        return

    valid_count = 0

    for path in csv_files:
        try:
            with path.open(
                "r",
                encoding="utf-8-sig",
                newline="",
            ) as file_handle:
                rows = list(csv.reader(file_handle))
        except (OSError, UnicodeDecodeError, csv.Error) as exc:
            add_error(f"CSV ilegível em {relative(path)}: {exc}")
            continue

        non_empty_rows = [
            row
            for row in rows
            if any(cell.strip() for cell in row)
        ]

        if not non_empty_rows:
            add_error(f"CSV vazio: {relative(path)}")
            continue

        header = non_empty_rows[0]

        if not header:
            add_error(f"CSV sem cabeçalho: {relative(path)}")
            continue

        if len(set(header)) != len(header):
            add_error(f"CSV com colunas duplicadas: {relative(path)}")

        expected_columns = len(header)
        inconsistent_rows: list[int] = []

        for row_number, row in enumerate(non_empty_rows[1:], start=2):
            if len(row) != expected_columns:
                inconsistent_rows.append(row_number)

        if inconsistent_rows:
            displayed_rows = ", ".join(
                str(row_number)
                for row_number in inconsistent_rows[:10]
            )
            add_error(
                f"CSV com quantidade inconsistente de colunas em "
                f"{relative(path)}; linha(s): {displayed_rows}"
            )
            continue

        relative_name = relative(path)
        expected_rows = EXPECTED_CSV_ROWS.get(relative_name)
        actual_rows = len(non_empty_rows) - 1

        if expected_rows is not None and actual_rows != expected_rows:
            add_error(
                f"CSV com quantidade inesperada de registros em "
                f"{relative_name}: esperado={expected_rows}, obtido={actual_rows}"
            )
            continue

        valid_count += 1

    if valid_count == len(csv_files):
        add_pass(f"Validação de CSV ({valid_count} arquivo(s))")


def normalize_markdown_target(raw_target: str) -> str:
    target = raw_target.strip()

    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1].strip()

    if " " in target and not target.startswith(("http://", "https://")):
        target = target.split(" ", 1)[0].strip()

    return unquote(target)


def should_ignore_link(target: str) -> bool:
    ignored_prefixes = (
        "http://",
        "https://",
        "mailto:",
        "tel:",
        "data:",
        "#",
        "javascript:",
    )

    return not target or target.lower().startswith(ignored_prefixes)


def audit_markdown_links() -> None:
    markdown_files = sorted(ROOT.rglob("*.md"))
    broken_links: list[str] = []
    checked_links = 0

    for markdown_file in markdown_files:
        content = read_text(markdown_file)

        for match in MARKDOWN_LINK_PATTERN.finditer(content):
            target = normalize_markdown_target(match.group(1))

            if should_ignore_link(target):
                continue

            path_part = target.split("#", 1)[0].split("?", 1)[0]

            if not path_part:
                continue

            if path_part.startswith("/"):
                destination = ROOT / path_part.lstrip("/")
            else:
                destination = markdown_file.parent / path_part

            try:
                resolved_destination = destination.resolve()
                resolved_destination.relative_to(ROOT.resolve())
            except ValueError:
                broken_links.append(
                    f"{relative(markdown_file)} -> {target} "
                    f"(fora do repositório)"
                )
                continue

            checked_links += 1

            if not resolved_destination.exists():
                broken_links.append(
                    f"{relative(markdown_file)} -> {target}"
                )

    if broken_links:
        for broken_link in broken_links:
            add_error(f"Link Markdown local inválido: {broken_link}")
    else:
        add_pass(
            f"Links Markdown locais ({checked_links} referência(s) verificadas)"
        )


def audit_sensitive_patterns() -> None:
    findings: list[str] = []

    for path in iter_repository_files():
        if path.suffix.lower() not in TEXT_EXTENSIONS:
            continue

        content = read_text(path)

        if not content:
            continue

        for label, pattern in SENSITIVE_PATTERNS:
            for match in pattern.finditer(content):
                line_number = content.count("\n", 0, match.start()) + 1
                findings.append(
                    f"{label}: {relative(path)}:{line_number}"
                )

    if findings:
        for finding in sorted(set(findings)):
            add_error(f"Padrão sensível encontrado: {finding}")
    else:
        add_pass("Ausência de padrões sensíveis no conteúdo atual")


def strip_sql_comments(content: str) -> str:
    without_block_comments = re.sub(
        r"/\*.*?\*/",
        "",
        content,
        flags=re.DOTALL,
    )

    without_line_comments = re.sub(
        r"--[^\n]*",
        "",
        without_block_comments,
    )

    return without_line_comments


def audit_sql_examples() -> None:
    missing_files = [
        file_name
        for file_name in EXPECTED_SQL_FILES
        if not (ROOT / file_name).is_file()
    ]

    if missing_files:
        for file_name in missing_files:
            add_error(f"Script SQL esperado ausente: {file_name}")
        return

    forbidden_dml = re.compile(
        r"\b(?:INSERT|UPDATE|DELETE|MERGE|TRUNCATE|DROP)\b",
        re.IGNORECASE,
    )

    valid_count = 0

    for file_name in EXPECTED_SQL_FILES:
        path = ROOT / file_name
        content = read_text(path)
        executable_content = strip_sql_comments(content)

        if not content.strip():
            add_error(f"Script SQL vazio: {file_name}")
            continue

        matches = sorted(
            {
                match.group(0).upper()
                for match in forbidden_dml.finditer(executable_content)
            }
        )

        if matches:
            add_error(
                f"SQL contém operação não prevista em {file_name}: "
                f"{', '.join(matches)}"
            )
            continue

        if "sheets-bq-sandbox-pipeline" not in content:
            add_error(
                f"SQL sem identificador sintético do projeto: {file_name}"
            )
            continue

        if "sandbox_pipeline_example" not in content:
            add_error(
                f"SQL sem dataset sintético esperado: {file_name}"
            )
            continue

        if not re.search(r"\bCREATE\b", executable_content, re.IGNORECASE):
            add_error(f"SQL sem criação de objeto: {file_name}")
            continue

        valid_count += 1

    if valid_count == len(EXPECTED_SQL_FILES):
        add_pass(
            f"Exemplos SQL ({valid_count} arquivo(s), sem DML destrutivo)"
        )


def audit_apps_script_examples() -> None:
    missing_files = [
        file_name
        for file_name in EXPECTED_APPS_SCRIPT_FILES
        if not (ROOT / file_name).is_file()
    ]

    if missing_files:
        for file_name in missing_files:
            add_error(f"Exemplo Apps Script ausente: {file_name}")
        return

    config_path = ROOT / "src/apps-script/config.example.gs"
    config_content = read_text(config_path)

    required_config_markers = [
        "sheets-bq-sandbox-pipeline",
        "sandbox_pipeline_example",
        "syntheticDataOnly",
        "retentionDays",
        "publication",
        "manualExecutionOnly",
        "manualAuthorizationRequired",
        "writeFormulas",
    ]

    missing_markers = [
        marker
        for marker in required_config_markers
        if marker not in config_content
    ]

    for marker in missing_markers:
        add_error(
            f"Configuração Apps Script sem marcador obrigatório: {marker}"
        )

    safety_patterns = {
        "syntheticDataOnly habilitado": re.compile(
            r"syntheticDataOnly\s*:\s*true"
        ),
        "execução exclusivamente manual": re.compile(
            r"manualExecutionOnly\s*:\s*true"
        ),
        "autorização manual obrigatória": re.compile(
            r"manualAuthorizationRequired\s*:\s*true"
        ),
        "publicação desabilitada por padrão": re.compile(
            r"publication\s*:\s*Object\.freeze\s*\(\s*\{.*?"
            r"enabled\s*:\s*false",
            re.DOTALL,
        ),
        "escrita de fórmulas desabilitada": re.compile(
            r"writeFormulas\s*:\s*false"
        ),
    }

    for description, pattern in safety_patterns.items():
        if not pattern.search(config_content):
            add_error(
                f"Configuração Apps Script não comprovou: {description}"
            )

    if not missing_markers and all(
        pattern.search(config_content)
        for pattern in safety_patterns.values()
    ):
        add_pass(
            "Configuração de segurança dos exemplos Apps Script"
        )

    non_empty_files = 0

    for file_name in EXPECTED_APPS_SCRIPT_FILES:
        content = read_text(ROOT / file_name)

        if not content.strip():
            add_error(f"Exemplo Apps Script vazio: {file_name}")
            continue

        non_empty_files += 1

    if non_empty_files == len(EXPECTED_APPS_SCRIPT_FILES):
        add_pass(
            f"Exemplos Apps Script ({non_empty_files} arquivo(s))"
        )


def audit_license() -> None:
    license_path = ROOT / "LICENSE"

    if not license_path.is_file():
        add_error("Arquivo LICENSE ausente")
        return

    content = read_text(license_path)

    required_fragments = [
        "Apache License",
        "Version 2.0, January 2004",
        "TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION",
        "END OF TERMS AND CONDITIONS",
    ]

    missing_fragments = [
        fragment
        for fragment in required_fragments
        if fragment not in content
    ]

    if missing_fragments:
        for fragment in missing_fragments:
            add_error(
                f"LICENSE não contém trecho obrigatório: {fragment}"
            )
    else:
        add_pass("Apache License 2.0")


def audit_readme() -> None:
    readme_path = ROOT / "README.md"

    if not readme_path.is_file():
        add_error("README.md ausente")
        return

    content = read_text(readme_path)

    required_fragments = [
        "assets/cover/repository-cover.png",
        "# Google Sheets to BigQuery Sandbox Pipeline",
        "Apache License 2.0",
        "docs/results.md",
        "docs/methodology.md",
        "docs/sandbox-and-billing.md",
        "examples/synthetic-data/",
        "src/apps-script/",
        "src/sql/",
    ]

    missing_fragments = [
        fragment
        for fragment in required_fragments
        if fragment not in content
    ]

    for fragment in missing_fragments:
        add_error(f"README sem referência obrigatória: {fragment}")

    h1_count = len(
        re.findall(
            r"(?m)^# (?!#)",
            content,
        )
    )

    if h1_count != 1:
        add_error(
            f"README deve possuir exatamente um título H1; obtido={h1_count}"
        )

    if "license-under%20review" in content:
        add_error("README ainda utiliza badge de licença em avaliação")

    if "A licença deste repositório ainda está em avaliação" in content:
        add_error("README ainda informa que a licença está em avaliação")

    if not missing_fragments and h1_count == 1:
        add_pass("Estrutura e referências principais do README")


def audit_cover() -> None:
    cover_path = ROOT / "assets/cover/repository-cover.png"

    if not cover_path.is_file():
        add_error("Capa ausente: assets/cover/repository-cover.png")
        return

    size = cover_path.stat().st_size

    if size == 0:
        add_error("A capa está vazia")
        return

    if size > 5 * 1024 * 1024:
        add_warning(
            f"A capa possui mais de 5 MiB: {size / 1024 / 1024:.2f} MiB"
        )

    signature = cover_path.read_bytes()[:8]
    expected_png_signature = b"\x89PNG\r\n\x1a\n"

    if signature != expected_png_signature:
        add_error(
            "repository-cover.png não possui assinatura válida de PNG"
        )
        return

    add_pass(
        f"Capa PNG ({size / 1024:.1f} KiB)"
    )


def audit_repository() -> None:
    audit_required_structure()
    audit_prohibited_files()
    audit_json_files()
    audit_csv_files()
    audit_markdown_links()
    audit_sensitive_patterns()
    audit_sql_examples()
    audit_apps_script_examples()
    audit_license()
    audit_readme()
    audit_cover()


def print_report() -> None:
    print("=" * 72)
    print("REPOSITORY AUDIT")
    print("=" * 72)
    print(f"Repository: {ROOT}")
    print()

    if PASSES:
        print("APPROVED CHECKS")
        print("-" * 72)
        for item in PASSES:
            print(f"[PASS] {item}")
        print()

    if WARNINGS:
        print("WARNINGS")
        print("-" * 72)
        for item in WARNINGS:
            print(f"[WARN] {item}")
        print()

    if ERRORS:
        print("ERRORS")
        print("-" * 72)
        for item in ERRORS:
            print(f"[FAIL] {item}")
        print()

    print("SUMMARY")
    print("-" * 72)
    print(f"Passed checks: {len(PASSES)}")
    print(f"Warnings: {len(WARNINGS)}")
    print(f"Errors: {len(ERRORS)}")

    if ERRORS:
        print("Final verdict: BLOCKED")
    elif WARNINGS:
        print("Final verdict: APPROVED_WITH_WARNINGS")
    else:
        print("Final verdict: APPROVED")

    print("=" * 72)


def main() -> int:
    audit_repository()
    print_report()

    return 1 if ERRORS else 0


if __name__ == "__main__":
    sys.exit(main())
