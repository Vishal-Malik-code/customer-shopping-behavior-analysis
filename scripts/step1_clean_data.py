"""
Step 1 - Data cleaning & feature engineering.

Reads the raw CSV, cleans it, engineers new features and writes:
  * data/processed/customer_shopping_data_clean.csv
  * data/customer_behavior.db   (SQLite database, table `customer`)

Run:  python scripts/step1_clean_data.py
"""
from pathlib import Path
import sqlite3

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw" / "customer_shopping_data_raw.csv"
CLEAN = ROOT / "data" / "processed" / "customer_shopping_data_clean.csv"
DB = ROOT / "data" / "customer_behavior.db"

# How many days between purchases each frequency label represents
FREQUENCY_TO_DAYS = {
    "Weekly": 7,
    "Bi-Weekly": 14,
    "Fortnightly": 14,
    "Monthly": 30,
    "Quarterly": 90,
    "Every 3 Months": 90,
    "Annually": 365,
}


def to_snake_case(columns: pd.Index) -> pd.Index:
    """'Purchase Amount (USD)' -> 'purchase_amount_usd'"""
    return (
        columns.str.strip()
        .str.lower()
        .str.replace(r"[()]", "", regex=True)
        .str.replace(r"\s+", "_", regex=True)
    )


def clean(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = to_snake_case(df.columns)
    df = df.rename(columns={"purchase_amount_usd": "purchase_amount"})

    # 1. Exact duplicate rows
    df = df.drop_duplicates()

    # 2. Missing review ratings -> median rating of the same category
    #    (ratings differ by category, so a global median would bias the data)
    df["review_rating"] = df.groupby("category")["review_rating"].transform(
        lambda s: s.fillna(s.median())
    )

    # 3. Redundant column: promo_code_used is identical to discount_applied
    if (df["discount_applied"] == df["promo_code_used"]).all():
        df = df.drop(columns="promo_code_used")

    # 4. Feature engineering
    df["age_group"] = pd.cut(
        df["age"],
        bins=[17, 30, 45, 60, 120],
        labels=["18-30", "31-45", "46-60", "60+"],
    )
    df["purchase_frequency_days"] = df["frequency_of_purchases"].map(FREQUENCY_TO_DAYS)
    df["est_purchases_per_year"] = (365 / df["purchase_frequency_days"]).round(1)

    df["customer_segment"] = np.select(
        [df["previous_purchases"] <= 1, df["previous_purchases"] <= 10],
        ["New", "Returning"],
        default="Loyal",
    )
    return df


def main() -> None:
    raw = pd.read_csv(RAW, encoding="utf-8-sig")
    print(f"Raw shape: {raw.shape}")
    print(f"Missing values before cleaning:\n{raw.isna().sum()[raw.isna().sum() > 0]}\n")

    df = clean(raw)
    assert df.isna().sum().sum() == 0, "Unexpected missing values after cleaning"

    CLEAN.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN, index=False)

    with sqlite3.connect(DB) as conn:
        df.to_sql("customer", conn, if_exists="replace", index=False)

    print(f"Clean shape: {df.shape}")
    print(f"Saved -> {CLEAN.relative_to(ROOT)}")
    print(f"Saved -> {DB.relative_to(ROOT)} (table: customer)")


if __name__ == "__main__":
    main()
