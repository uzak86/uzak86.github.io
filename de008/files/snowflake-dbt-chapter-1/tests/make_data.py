"""de008 synthetic data: online-shop customers + orders exports (seeded, reproducible).
Planted problems (what chapter 1's tests catch):
  1. 12 orders appear twice (the export job wrote one batch twice) -> 5,012 rows for 5,000 orders
  2. status arrives in mixed case for some rows ('Completed', 'REFUNDED')
No real people or companies."""
from __future__ import annotations
import csv, random
from datetime import datetime, timedelta
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "data"
rng = random.Random(20261031)

def main() -> None:
    OUT.mkdir(exist_ok=True)
    customers = []
    start = datetime(2025, 1, 1)
    for i in range(1, 501):
        customers.append({"customer_id": f"C{i:04d}",
                          "signup_date": (start + timedelta(days=rng.randrange(0, 600))).date().isoformat(),
                          "country": rng.choice(["GB"] * 9 + ["IE"])})
    with open(OUT / "customers.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(customers[0])); w.writeheader(); w.writerows(customers)

    orders = []
    t0 = datetime(2026, 10, 1)
    for i in range(1, 5001):
        st = rng.choices(["completed", "refunded", "cancelled"], weights=[85, 8, 7])[0]
        orders.append({"order_id": f"O{i:05d}",
                       "customer_id": rng.choice(customers)["customer_id"],
                       "order_ts": (t0 + timedelta(seconds=rng.randrange(0, 31 * 86400))).strftime("%Y-%m-%d %H:%M:%S"),
                       "status": st,
                       "amount_gbp": f"{rng.randrange(500, 25000) / 100:.2f}"})
    for o in rng.sample(orders, 60):          # planted problem 2: mixed-case status
        o["status"] = rng.choice([o["status"].capitalize(), o["status"].upper()])
    dup_ids = set(rng.sample([o["order_id"] for o in orders if o["status"].lower() == "completed"], 12))
    rows = []
    for o in orders:                           # planted problem 1: one batch written twice
        rows.append(o)
        if o["order_id"] in dup_ids:
            rows.append(dict(o))
    with open(OUT / "orders.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(orders[0])); w.writeheader(); w.writerows(rows)

if __name__ == "__main__":
    main()
