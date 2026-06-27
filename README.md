# Google Maps Leads Scrapper

A Python toolkit for scraping business leads from Google Maps and enriching them with contact details (emails, phone numbers, social media links) pulled directly from each business's website.

Works for **any business category and location** — restaurants, plumbers, gyms, real estate agents, dentists, HVAC contractors, whatever you search for on Google Maps. Built originally to generate cold outreach lists, but useful for any kind of local business research.

## What It Does

1. **Google Maps Scraper** (`main.py`) — searches Google Maps for any business category + location, scrolls through the full results list until it hits the real end (not just the first page that loads), and extracts:
   - Business name
   - Address
   - Phone number
   - Website
   - Review count & average rating
   - Business type / category
   - Operating hours

2. **Duplicate Cleaner** (`clean_duplicates.py`) — scans exported CSV files and removes duplicate listings (Google Maps sometimes lists the same business twice).

3. **Lead Merger** (`merge_leads.py`) — combines multiple city/category CSV exports into a single master file, deduplicates across files, and flags leads that have no website (handy for prioritizing outreach, e.g. website-building pitches).

4. **Batch Automation** (`run_scraper_batches.ps1`) — a PowerShell script that automatically opens multiple terminal sessions and runs the scraper across a list of cities/searches in parallel batches, so you don't have to run each search manually one at a time.

## Prerequisites
- Python 3.8 or 3.9 (Python 3.10+ may have dependency issues)
- Google Chrome or Chromium installed (required by Playwright)

## Installation

```bash
git clone https://github.com/abdulrazzak10/Google-Maps-Leads-Scrapper.git
cd Google-Maps-Leads-Scrapper
pip install -r requirements.txt
playwright install
```

## Usage

### Single search
```bash
python main.py -s "plumbers in Austin TX" -o leads_austin.csv
```

```bash
python main.py -s "gyms in Brooklyn NY" -o leads_brooklyn.csv
```

| Flag | Description |
|------|--------------|
| `-s`, `--search` | Search query for Google Maps (any business type + location) |
| `-t`, `--total` | Max number of results to scrape. Leave unset to scrape until the list is fully exhausted |
| `-o`, `--output` | Output CSV file path |
| `--append` | Append to the output file instead of overwriting |

### Batch run across multiple cities/searches (Windows PowerShell)
Edit the search list inside `run_scraper_batches.ps1` with whatever category + cities you need, then run:
```powershell
powershell -ExecutionPolicy Bypass -File .\run_scraper_batches.ps1
```
This opens several terminal windows in parallel batches, scrapes each search into its own CSV, and waits between batches to avoid rate-limiting.

### Clean duplicates from existing exports
```bash
python clean_duplicates.py
```

### Merge all exports into one master file
```bash
python merge_leads.py
```
Outputs a combined master CSV with a `has_website` column flagging leads with no website found — useful if you're pitching website services.

## Notes
- The scraper runs a **visible** (non-headless) browser window — don't close it mid-run.
- Google Maps' page structure changes occasionally, which can break element selectors. If scraping stops returning data, the XPaths in `main.py` may need updating.
- Avoid running too many parallel scrapes back-to-back — pace your batches to avoid getting temporarily rate-limited by Google.
- This is for lead generation / business research purposes. Respect target sites' terms of service and applicable data/privacy laws when using scraped contact information.

## License
MIT<!-- updated -->
