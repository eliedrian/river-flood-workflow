#!/usr/bin/python3

import sys
import re
from pathlib import Path

import pandas as pd

# based on the matrix
def get_activation_level(severity_rp, probability):

    if severity_rp == 2:
        if probability >= 0.8:
            return "High"
        elif probability >= 0.6:
            return "Moderate"
        else:
            return "Monitoring/No Activation"

    elif severity_rp == 5:
        if probability >= 0.8:
            return "Very High"
        elif probability >= 0.6:
            return "High"
        elif probability >= 0.5:
            return "Moderate"
        else:
            return "Monitoring/No Activation"

    elif severity_rp == 10:
        if probability >= 0.6:
            return "Very High"
        elif probability >= 0.5:
            return "High"
        elif probability >= 0.35:
            return "Moderate"
        else:
            return "Monitoring/No Activation"

    elif severity_rp == 20:
        if probability >= 0.5:
            return "Very High"
        elif probability >= 0.35:
            return "High"
        else:
            return "Monitoring/No Activation"

    return "Monitoring/No Activation"


def main():

    # just in case
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <activation_csv>")
        sys.exit(1)

    csv_file = Path(sys.argv[1])

    # in case sayop ang csv filename - pero naa man syay pattern ang filename ana sa?
    if not csv_file.exists():
        print(f"Error: '{csv_file}' does not exist.")
        sys.exit(1)

    df = pd.read_csv(csv_file)
    df.columns = df.columns.str.strip()

    df["fired"] = (
        df["fired"]
        .astype(str)
        .str.strip()
        .str.lower()
        == "true"
    )

    fired_rows = df[df["fired"]]

    if fired_rows.empty:
        print("No activated river basins found.")
        return

    base_name = csv_file.stem

    for basin_name, group in fired_rows.groupby("basin_name"):
        highest = group.loc[group["severity_rp"].idxmax()]
        certainty = float(highest["probability_at_fire"]) * 100

        activation_level = get_activation_level(
            highest["severity_rp"],
            highest["probability_at_fire"]
        )

        safe_basin = re.sub(r'[<>:"/\\|?*]', "_", str(basin_name))

        csv_output = f"{base_name}_{safe_basin}_highest_severity.csv"
        txt_output = f"{base_name}_{safe_basin}_activation_summary.txt"

        highest.to_frame().T.to_csv(csv_output, index=False)

        with open(txt_output, "w") as f:
            f.write(f"River Basin: {basin_name}\n")
            f.write(f"Date: {highest['issue_date']}\n")
            f.write(f"Activation Status: {highest['fired']}\n")
            f.write(f"Severity Level: {activation_level}\n")
            f.write(
                f"Number of People estimated to be affected: "
                f"{int(highest['impact_population_at_fire']):,}\n"
            )
            f.write(f"Certainty Level: {certainty:.2f}%\n")
            f.write(f"Lead time: {highest['fire_lead']} days\n")

        print(f"\nRiver Basin: {basin_name}")
        print(f"  CSV : {csv_output}")
        print(f"  TXT : {txt_output}")

if __name__ == "__main__":
    main()
