#!/usr/bin/env python3

import re
from collections import Counter

LOG_FILE = "/home/stanley/labs/Stanley_Nzeadibe_Techrise_Week1to4/Part_C_Portfolio/week-3/log_analyser.py"
OUTPUT_FILE = "python_timeline.txt"
THRESHOLD = 3


def read_log(filepath):
    """Read log file safely."""
    try:
        with open(filepath, "r", errors="ignore") as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"[ERROR] File not found: {filepath}")
        return []
    except PermissionError:
        print(f"[ERROR] Permission denied: {filepath}")
        return []


def extract_failed_ips(lines):
    """Extract IPs from failed login attempts."""
    ip_pattern = r"\b(?:\d{1,3}\.){3}\d{1,3}\b"
    ips = []

    for line in lines:
        if "Failed password" in line:
            match = re.search(ip_pattern, line)
            if match:
                ips.append(match.group())

    return Counter(ips)


def generate_alerts(ip_counts):
    """Assign severity based on number of attempts."""
    alerts = []

    for ip, count in ip_counts.items():

        if count >= 5:
            severity = "HIGH"
        elif count >= 3:
            severity = "MEDIUM"
        else:
            severity = "LOW"

        alerts.append((severity, ip, count))

    return alerts


def build_timeline(lines):

    timeline = []

    for line in lines:

        if "Failed password" in line:
            timeline.append(("FAILED LOGIN", line.strip()))

        elif "Accepted password" in line:
            timeline.append(("SUCCESSFUL LOGIN", line.strip()))

        elif "session opened" in line:
            timeline.append(("SESSION OPENED", line.strip()))

        elif "sudo:" in line:
            timeline.append(("SUDO ACTIVITY", line.strip()))

    return timeline


def save_report(alerts, timeline):

    with open(OUTPUT_FILE, "w") as out:

        out.write("=====================================\n")
        out.write("Week 3 Python Security Timeline\n")
        out.write("=====================================\n\n")

        out.write("ATTACK ALERTS\n")
        out.write("-----------------------------\n")

        for severity, ip, count in sorted(alerts):
            out.write(f"[{severity}] {ip} : {count} failed attempts\n")

        out.write("\n")

        out.write("INCIDENT TIMELINE\n")
        out.write("-----------------------------\n")

        for event, details in timeline:
            out.write(f"{event}: {details}\n")


def main():

    lines = read_log(LOG_FILE)

    if not lines:
        return

    print(f"Read {len(lines)} log entries.")

    ip_counts = extract_failed_ips(lines)

    print("\nTop Attacking IPs")

    for ip, count in ip_counts.most_common(5):
        print(f"{ip} : {count}")

    alerts = generate_alerts(ip_counts)

    print(f"\nGenerated {len(alerts)} alerts.")

    timeline = build_timeline(lines)

    save_report(alerts, timeline)

    print(f"\nTimeline written to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
