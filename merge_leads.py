"""
merge_leads.py

Combines all leads_*.csv files in this folder into ONE master CSV file,
removes duplicate businesses (even if they appeared in multiple city files),
and flags leads that have NO website (best targets for website-upgrade pitch).

Usage:
    python merge_leads.py
"""
import pandas as pd
import glob
import os

OUTPUT_FILE = "all_hvac_leads_master.csv"

csv_files = glob.glob("leads_*.csv")

if not csv_files:
    print("No leads_*.csv files found in this folder.")
else:
    print(f"Found {len(csv_files)} files to merge:")
    for f in csv_files:
        print(f"  - {f}")
    print()

    all_dfs = []
    for file in csv_files:
        try:
            df = pd.read_csv(file)
            # Track which city file each lead originally came from
            df["source_file"] = os.path.basename(file)
            all_dfs.append(df)
        except Exception as e:
            print(f"Skipping {file} due to error: {e}")

    # Combine everything into one big table
    master_df = pd.concat(all_dfs, ignore_index=True)
    total_before = len(master_df)

    # Remove duplicates across ALL cities (same business might show up twice
    # if it operates in overlapping areas, or appears in two searches)
    if "phone_number" in master_df.columns and "name" in master_df.columns:
        master_df = master_df.drop_duplicates(subset=["name", "phone_number"], keep="first")
    elif "name" in master_df.columns:
        master_df = master_df.drop_duplicates(subset=["name"], keep="first")

    total_after = len(master_df)
    removed = total_before - total_after

    # Flag leads with no website -- these are your hottest leads for
    # pitching website creation / upgrade services
    if "website" in master_df.columns:
        master_df["has_website"] = master_df["website"].notna() & (master_df["website"].astype(str).str.strip() != "")
        master_df["has_website"] = master_df["has_website"].map({True: "Yes", False: "No"})
    else:
        master_df["has_website"] = "Unknown"

    # Save the final combined file
    master_df.to_csv(OUTPUT_FILE, index=False)

    no_website_count = (master_df["has_website"] == "No").sum()

    print(f"Total leads before merging: {total_before}")
    print(f"Duplicates removed: {removed}")
    print(f"Final unique leads: {total_after}")
    print(f"Leads with NO website (hot leads for website pitch): {no_website_count}")
    print(f"\nSaved combined file as: {OUTPUT_FILE}")
# updated
