"""
clean_duplicates.py

Run this to remove duplicate rows from all your already-scraped leads_*.csv files.
Usage:
    python clean_duplicates.py
"""
import pandas as pd
import glob
import os

# Finds every leads_*.csv file in the current folder
csv_files = glob.glob("leads_*.csv")

if not csv_files:
    print("No leads_*.csv files found in this folder.")
else:
    for file in csv_files:
        df = pd.read_csv(file)
        before = len(df)

        if "phone_number" in df.columns and "name" in df.columns:
            df = df.drop_duplicates(subset=["name", "phone_number"], keep="first")
        elif "name" in df.columns:
            df = df.drop_duplicates(subset=["name"], keep="first")
        else:
            df = df.drop_duplicates(keep="first")

        after = len(df)
        removed = before - after

        df.to_csv(file, index=False)
        print(f"{file}: {before} -> {after} rows (removed {removed} duplicates)")

print("\nDone! All files cleaned.")
# updated
