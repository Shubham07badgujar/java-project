#!/usr/bin/env python3
"""
Script to insert parameter values for the second spacecraft (chandra)
This demonstrates manual data insertion for educational purposes
"""

import sqlite3
import sys

def insert_chandra_spacecraft_data():
    """Insert data for the chandra spacecraft"""
    
    # Connect to the database
    conn = sqlite3.connect('spacecraft.db')
    cursor = conn.cursor()
    
    print("=== Inserting Data for CHANDRA Spacecraft ===\n")
    
    # Sample data for chandra spacecraft
    chandra_records = [
        {
            'page_id': 'CHAN-COM-002',
            'page_no': 2,
            'spacecraft_name': 'chandra',
            'subsystem_name': 'communication',
            'record_title': 'Communication System Parameters',
            'parameters': {
                'Spacecraft Name': 'CHANDRA X-Ray Observatory',
                'Mission ID': 'CHAN-001',
                'Launch Date': '1999-07-23',
                'Orbit Type': 'Highly Elliptical Orbit',
                'Payload Capacity': '4800 kg',
                'Communication Band': 'S-band, Ka-band',
                'Power Output': '2.35 kW',
                'Solar Array Size': '27.4 m²',
                'Operational Lifetime': '5+ years (extended)',
                'Data Rate': '32 kbps',
                'Ground Stations': 'DSN, Madrid, Goldstone',
                'Mission Objectives': 'X-ray astronomy observations'
            }
        },
        {
            'page_id': 'CHAN-POW-003',
            'page_no': 3,
            'spacecraft_name': 'chandra',
            'subsystem_name': 'power',
            'record_title': 'Power System Specifications',
            'parameters': {
                'Spacecraft Name': 'CHANDRA X-Ray Observatory',
                'Power Output': '2.35 kW peak',
                'Solar Array Size': '27.4 m² effective area',
                'Battery Capacity': '40 Ah NiH2',
                'Engine Type': 'Hydrazine thrusters',
                'Max Thrust': '4.45 N',
                'Fuel Capacity': '1395 kg hydrazine',
                'Temperature Range': '-150°C to +200°C',
                'Thermal Control': 'Passive radiators + heaters',
                'Redundancy Level': 'Triple redundant systems'
            }
        }
    ]
    
    try:
        for record in chandra_records:
            # Insert into Page_Info table
            print(f"Inserting Page_Info record: {record['page_id']}")
            cursor.execute("""
                INSERT OR REPLACE INTO Page_Info 
                (PageID, PageNo, SpacecraftName, SubsystemName, RecordTitle) 
                VALUES (?, ?, ?, ?, ?)
            """, (
                record['page_id'],
                record['page_no'],
                record['spacecraft_name'],
                record['subsystem_name'],
                record['record_title']
            ))
            
            # Prepare data for Page_Data table
            page_data = [record['page_id']]  # Start with PageID
            
            # Add all the parameter values in order
            parameter_columns = [
                'Spacecraft Name', 'Mission ID', 'Launch Date', 'Orbit Type', 
                'Payload Capacity', 'Fuel Capacity', 'Max Thrust', 'Engine Type',
                'Communication Band', 'Power Output', 'Solar Array Size', 'Battery Capacity',
                'Attitude Control', 'Navigation System', 'Thermal Control', 'Structural Material',
                'Dry Mass', 'Wet Mass', 'Dimensions', 'Operational Lifetime',
                'Data Rate', 'Onboard Storage', 'Redundancy Level', 'Failure Rate',
                'Reliability', 'Radiation Tolerance', 'Temperature Range', 'Software Version',
                'Firmware Version', 'Autonomy Level', 'Mission Objectives', 'Scientific Instruments',
                'Propulsion System', 'Delta-V Capacity', 'Communication Delay', 'Ground Stations',
                'Mission Cost', 'Development Time', 'RecordTitle', 'PageNo', 'SpacecraftName',
                'SubsystemName'
            ]
            
            # Add parameter values
            for col in parameter_columns:
                page_data.append(record['parameters'].get(col, ''))
            
            # Add the additional Parameter 1-37 columns (empty for now)
            for i in range(1, 38):
                page_data.append('')
            
            # Add two more empty columns to match the 82 total columns
            page_data.append('')
            page_data.append('')
            
            # Insert into Page_Data table
            print(f"Inserting Page_Data record: {record['page_id']}")
            placeholders = ', '.join(['?' for _ in page_data])
            cursor.execute(f"INSERT OR REPLACE INTO Page_Data VALUES ({placeholders})", page_data)
            
            print(f"✓ Successfully inserted record {record['page_id']}")
            print()
        
        # Commit the changes
        conn.commit()
        print("=== All CHANDRA spacecraft data inserted successfully! ===")
        
        # Display inserted records
        print("\n=== Verification: Showing inserted records ===")
        cursor.execute("SELECT PageID, PageNo, SpacecraftName, SubsystemName, RecordTitle FROM Page_Info WHERE SpacecraftName = 'chandra' ORDER BY PageNo")
        records = cursor.fetchall()
        
        for record in records:
            print(f"Page ID: {record[0]}, Page No: {record[1]}, Subsystem: {record[3]}, Title: {record[4]}")
            
    except Exception as e:
        print(f"Error inserting data: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    insert_chandra_spacecraft_data()
