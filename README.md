# LocalisationAutomation

> Ruby scripts to convert between CSV and iOS localisation files, plus a diff tool to verify nothing was lost.

Three small helpers for managing iOS app localisations:

- **`csvToLangFiles.rb`** — generate `Localizable.strings` files from a master CSV
- **`langFilesTocsv.rb`** — export existing `Localizable.strings` files to a CSV
- **`langToLangCompare.rb`** — compare two localisation sets to verify nothing was lost

## Requirements

- Ruby 2.7+

---

## csvToLangFiles.rb

Generates `.strings` files from a `localization.csv` file based on the current folder hierarchy.

### Usage

1. Update the `"CHANGE ME TO YOUR OUTPUT DIRECTORY"` string inside the script with your target output path.
2. Copy your `localization.csv` file into the `LocalisationAutomation/` folder.
3. From a terminal inside `LocalisationAutomation/`, run:
   ```bash
   ruby csvToLangFiles.rb localization.csv
   ```

---

## langFilesTocsv.rb

Creates a `localization.csv` from existing `.strings` files. Typically used once per project to bootstrap the CSV.

### Usage

1. Create a `CurrentLocalization/` folder inside `LocalisationAutomation/`.
2. Copy all relevant `*.lproj` folders into `CurrentLocalization/` — each should contain only the `Localizable.strings` file.
3. From a terminal inside `LocalisationAutomation/`, run:
   ```bash
   ruby langFilesTocsv.rb
   ```
4. The generated `localization.csv` appears in the `Generated/` folder.

---

## langToLangCompare.rb

Compares the original localisation with a generated one to verify nothing was lost or broken. Useful as a sanity check when iterating on the conversion scripts.

### Usage

1. Create a `CurrentLocalization/` folder inside `LocalisationAutomation/`.
2. Copy all relevant `*.lproj` folders into `CurrentLocalization/`.
3. Place the generated localisation inside `LocalisationAutomation/Generated/` with the same structure as `CurrentLocalization/`.
4. From a terminal inside `LocalisationAutomation/`, run:
   ```bash
   ruby langToLangCompare.rb
   ```
5. The diff appears as `localization_diff.txt` in the `Generated/` folder.

---

## License

Released under the **MIT License**. See the [LICENSE](LICENSE) file for details.

Copyright © 2026 Dmitry Protopopov (github.com/Dimajp).
