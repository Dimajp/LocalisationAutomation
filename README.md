————————————
csvToLangFiles.rb

Generates localisation files from provided localization.csv file for our project based on current folder hierarchy

Usage: 
- do not forget to update "CHANGE ME TO YOUR OUTPUT DIRECTORY" string
- copy past localization.csv file inside LocalisationAutomation folder
- in terminal inside LocalisationAutomation folder run “ruby csvToLangFiles.rb localization.csv”


————————————
langFilesTocsv.rb

Helping script to create localization.csv from existent localisation files. 
Ideally should be used only once per project.

Usage:
- create CurrentLocalization folder inside LocalisationAutomation
- copy inside CurrentLocalization all necessary *.lproj folders with only Localizable.strings file inside them
- in terminal inside LocalisationAutomation folder run “ruby langFilesTocsv.rb”
- get localization.csv from Generated folder


————————————
langToLangCompare.rb

Helping script to compare initial localisation with generated one. 
Used as a test functionality to tune up localisation scripts to be sure noting is lost/broken.

Usage:
- create CurrentLocalization folder inside LocalisationAutomation
- copy inside CurrentLocalization all necessary *.lproj folders with only Localizable.strings file inside them
- put generated localisation inside Generated folder (LocalisationAutomation/Generated) with the same structure as for CurrentLocalization
- in terminal inside LocalisationAutomation folder run “ruby langToLangCompare.rb”
- get localization_diff.txt from Generated folder


————————————
License

Released under the MIT License. See the LICENSE file for details.
Copyright © 2026 Dmitry Protopopov (github.com/Dimajp).
