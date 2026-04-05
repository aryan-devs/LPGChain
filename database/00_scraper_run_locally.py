"""
Pune LPG Distributor Scraper
Scrapes real distributor data from locator.iocl.com for Pune, Maharashtra
Outputs: pune_distributors.csv
"""

import requests
from bs4 import BeautifulSoup
import csv
import time
import re
import json

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-IN,en;q=0.9",
}

# Pune areas/localities to scrape
PUNE_AREAS = [
    "pune",
    "pune/hinjewadi",
    "pune/aundh",
    "pune/wakad",
    "pune/kothrud",
    "pune/hadapsar",
    "pune/pimpri",
    "pune/chinchwad",
    "pune/baner",
    "pune/viman-nagar",
    "pune/kharadi",
    "pune/kondhwa",
    "pune/sinhagad-road",
    "pune/katraj",
    "pune/bibwewadi",
    "pune/deccan",
    "pune/shivajinagar",
    "pune/koregaon-park",
    "pune/mundhwa",
    "pune/undri",
]

BASE_URL = "https://locator.iocl.com/indane/location/maharashtra/{area}"

def parse_distributor_card(card):
    """Extract fields from a single distributor listing card."""
    data = {}

    # Name
    name_tag = card.find("h3") or card.find(class_=re.compile("name|title", re.I))
    data["name"] = name_tag.get_text(strip=True) if name_tag else ""

    # Address
    addr_tag = card.find("address") or card.find(class_=re.compile("address|addr", re.I))
    if addr_tag:
        data["address"] = addr_tag.get_text(separator=", ", strip=True)
    else:
        # fallback: grab paragraph text
        p_tags = card.find_all("p")
        data["address"] = " ".join(p.get_text(strip=True) for p in p_tags[:2])

    # Phone
    phone_tag = card.find("a", href=re.compile(r"tel:"))
    data["phone"] = phone_tag.get_text(strip=True) if phone_tag else ""

    # Pincode from address
    pin_match = re.search(r"\b4\d{5}\b", data.get("address", ""))
    data["pincode"] = pin_match.group() if pin_match else ""

    # Profile URL
    link_tag = card.find("a", href=re.compile(r"/indane/indane-"))
    data["profile_url"] = "https://locator.iocl.com" + link_tag["href"] if link_tag else ""

    return data


def scrape_area(area_slug, page=1):
    """Scrape one area page and return list of distributor dicts."""
    url = BASE_URL.format(area=area_slug)
    if page > 1:
        url += f"?page={page}"

    try:
        resp = requests.get(url, headers=HEADERS, timeout=15)
        if resp.status_code != 200:
            print(f"  ✗ {area_slug} page {page} → HTTP {resp.status_code}")
            return [], False

        soup = BeautifulSoup(resp.text, "html.parser")

        # Find distributor cards — IOCL uses various class names
        cards = (
            soup.find_all("div", class_=re.compile("listing|agency|dealer|result", re.I))
            or soup.find_all("li", class_=re.compile("listing|agency|dealer", re.I))
            or soup.find_all("article")
        )

        distributors = []
        for card in cards:
            d = parse_distributor_card(card)
            if d.get("name"):
                d["area_slug"] = area_slug.split("/")[-1].replace("-", " ").title()
                d["company"] = "IOCL (IndaneGas)"
                distributors.append(d)

        # Check for next page
        next_btn = soup.find("a", string=re.compile("next|›|»", re.I)) or \
                   soup.find("a", class_=re.compile("next", re.I))
        has_next = bool(next_btn)

        print(f"  ✓ {area_slug} page {page} → {len(distributors)} distributors found")
        return distributors, has_next

    except Exception as e:
        print(f"  ✗ {area_slug} page {page} → Error: {e}")
        return [], False


def scrape_all():
    all_distributors = []
    seen_names = set()

    for area in PUNE_AREAS:
        print(f"\n📍 Scraping: {area}")
        page = 1
        while True:
            distributors, has_next = scrape_area(area, page)
            for d in distributors:
                key = d.get("name", "").lower().strip()
                if key and key not in seen_names:
                    seen_names.add(key)
                    all_distributors.append(d)
            if not has_next or not distributors:
                break
            page += 1
            time.sleep(1.2)  # polite delay
        time.sleep(1.0)

    return all_distributors


def save_csv(distributors, filename="pune_distributors.csv"):
    if not distributors:
        print("\n⚠️  No data scraped. The site may require JS rendering.")
        print("   → Run the Selenium fallback script instead.")
        return

    fields = ["name", "area_slug", "address", "pincode", "phone", "company", "profile_url"]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(distributors)

    print(f"\n✅ Saved {len(distributors)} distributors → {filename}")


if __name__ == "__main__":
    print("🔍 Pune LPG Distributor Scraper — IOCL IndaneGas")
    print("=" * 50)
    distributors = scrape_all()
    save_csv(distributors, "/mnt/user-data/outputs/pune_distributors.csv")
    print("\nDone! Check pune_distributors.csv")
