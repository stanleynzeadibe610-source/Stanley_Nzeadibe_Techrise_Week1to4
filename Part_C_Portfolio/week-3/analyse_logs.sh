#!/bin/bash

LOGFILE="/home/kali/labs/PETER_SHADRACH_CHIGOZIE_Techrise_Weeks1to4/Part_C_Portfolio/week-1/paylite_auth.log"
REPORT="bash_report.txt"
DATE=$(date)

# Check if log file exists
if [ ! -f "$LOGFILE" ]; then
    echo "[ERROR] Log file '$LOGFILE' not found."
    exit 1
fi
echo "==========================================" > "$REPORT"
echo "Week 3 Security Log Analysis Report" >> "$REPORT"
echo "Generated: $DATE" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "" >> "$REPORT"

TOTAL=$(wc -l < "$LOGFILE")

if [ "$TOTAL" -gt 0 ]; then
    echo "Total Log Entries: $TOTAL" >> "$REPORT"
else
    echo "Log file is empty." >> "$REPORT"
    exit 0
fi

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "FAILED LOGIN ATTEMPTS" >> "$REPORT"
echo "==========================================" >> "$REPORT"

grep "Failed password" "$LOGFILE" >> "$REPORT"

FAILED=$(grep -c "Failed password" "$LOGFILE")
echo "" >> "$REPORT"
echo "Total Failed Attempts: $FAILED" >> "$REPORT"

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "SUCCESSFUL LOGINS" >> "$REPORT"
echo "==========================================" >> "$REPORT"

grep "Accepted password" "$LOGFILE" >> "$REPORT"

SUCCESS=$(grep -c "Accepted password" "$LOGFILE")
echo "" >> "$REPORT"
echo "Total Successful Logins: $SUCCESS" >> "$REPORT"

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "SUDO ACTIVITY" >> "$REPORT"
echo "==========================================" >> "$REPORT"

grep "sudo:" "$LOGFILE" >> "$REPORT"

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "TOP ATTACKING IP ADDRESSES" >> "$REPORT"
echo "==========================================" >> "$REPORT"

grep "Failed password" "$LOGFILE" \
| awk '{print $(NF-2)}' \
| sort \
| uniq -c \
| sort -rn >> "$REPORT"

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "TARGETED USER ACCOUNTS" >> "$REPORT"
echo "==========================================" >> "$REPORT"

grep "Failed password" "$LOGFILE" \
| awk '{print $9}' \
| sort \
| uniq -c >> "$REPORT"

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "SECURITY SUMMARY" >> "$REPORT"
echo "==========================================" >> "$REPORT"

for IP in $(grep "Failed password" "$LOGFILE" | awk '{print $(NF-2)}' | sort -u)
do
    COUNT=$(grep -c "$IP" "$LOGFILE")

    if [ "$COUNT" -ge 5 ]; then
        echo "[HIGH] $IP generated $COUNT authentication events." >> "$REPORT"
    elif [ "$COUNT" -ge 3 ]; then
        echo "[MEDIUM] $IP generated $COUNT authentication events." >> "$REPORT"
    else
        echo "[LOW] $IP generated $COUNT authentication events." >> "$REPORT"
    fi
done

echo "" >> "$REPORT"
echo "Analysis completed successfully." >> "$REPORT"

echo "Report saved as $REPORT"
