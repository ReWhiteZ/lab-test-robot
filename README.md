# Lab 03 — Robot Framework และ SeleniumLibrary

คู่มือสร้างโปรเจกต์ Robot Framework ที่ใช้ SeleniumLibrary ตั้งแต่เริ่มต้น และอธิบายรูปแบบการเขียน test ด้วย Robot Framework โดยไม่ยึดกับโจทย์เฉพาะหน้าเว็บใด

## สิ่งที่ต้องมี

- Python 3.14 (โปรเจกต์นี้กำหนด `requires-python = ">=3.14"`)
- `uv` สำหรับสร้าง virtual environment และติดตั้งแพ็กเกจ
- Google Chrome หรือ Chromium

ตรวจสอบเครื่องมือด้วย `python --version` และ `uv --version` หลังติดตั้ง `uv` จากเอกสารทางการ Selenium Manager ของ SeleniumLibrary ช่วยจัดหา WebDriver อัตโนมัติในกรณีทั่วไป

## สร้างโปรเจกต์จากศูนย์

```powershell
uv init --python 3.14 robot-selenium-tests
cd robot-selenium-tests
uv add robotframework==7.5 robotframework-seleniumlibrary
New-Item -ItemType Directory tests
New-Item -ItemType Directory results
```

สร้างไฟล์ Robot เช่น `tests/browser_basics.robot` แล้วเริ่มจากโครงสร้างนี้:

```robot
*** Settings ***
Library    SeleniumLibrary
Test Teardown    Close All Browsers

*** Variables ***
${BASE_URL}    https://example.com

*** Test Cases ***
Open Example Page
    Open Browser    ${BASE_URL}    chrome
    Title Should Be    Example Domain
```

## โครงสร้างโปรเจกต์ตัวอย่าง

```text
robot-selenium-tests/
├── tests/
│   └── browser_basics.robot
├── results/             # รายงานที่สร้างตอนรัน ไม่จำเป็นต้อง commit
├── pyproject.toml
└── uv.lock
```

`pyproject.toml` ระบุ dependencies และ `uv.lock` ช่วยให้ติดตั้งเวอร์ชันเดิมซ้ำได้ ส่วน `results/` เก็บ `output.xml`, `log.html` และ `report.html`

## รูปแบบของไฟล์ Robot

- `*** Settings ***` ระบุ Library, Resource, Suite Setup/Teardown และ Test Setup/Teardown
- `*** Variables ***` เก็บค่าที่ใช้ซ้ำ เช่น URL หรือ timeout โดยเขียนเป็น `${NAME}`
- `*** Test Cases ***` เป็นรายการ test แต่ละกรณี เรียกใช้ keyword ตามลำดับ
- `*** Keywords ***` ใช้สร้างขั้นตอนที่นำกลับมาใช้ซ้ำได้ โดยเขียน keyword ให้สื่อความหมายทางธุรกิจหรือการกระทำ

ตัวอย่างการแยกขั้นตอนเป็น keyword:

```robot
*** Test Cases ***
Page Shows Expected Heading
    Open Browser    ${BASE_URL}    chrome
    Page Should Show Heading    Example Domain

*** Keywords ***
Page Should Show Heading
    [Arguments]    ${expected}
    Wait Until Page Contains Element    tag:h1    10s
    Element Text Should Be    tag:h1    ${expected}
```

Robot ใช้ช่องว่างอย่างน้อยสองช่องคั่นชื่อ keyword กับ argument จึงควรรักษาการจัด indent และ spacing ให้ถูกต้อง Assertion ของ SeleniumLibrary เช่น `Title Should Be`, `Element Text Should Be` และ `Location Should Be` จะทำให้ test fail เมื่อผลจริงไม่ตรงกับที่คาด

## รันโปรเจกต์นี้

จากโฟลเดอร์ Lab:

```powershell
uv sync
uv run robot --outputdir results tests
```

รันไฟล์เดียวได้ด้วย:

```powershell
uv run robot --outputdir results tests/saucedemo.robot
```

เปิด `results/report.html` เพื่อดูสรุป และ `results/log.html` เพื่อดูขั้นตอนและ keyword ที่ทำงาน หากต้องการใช้ Chrome แบบ headless ให้ตั้งค่า options ใน `Open Browser` หรือกำหนดค่าผ่าน variable/configuration ให้เหมาะกับโปรเจกต์

## แนวทางที่ควรทำ

- ใช้ keyword ระดับสูงที่อ่านแล้วเข้าใจขั้นตอน test ได้
- รวมการทำซ้ำเป็น keyword และพารามิเตอร์ด้วย `[Arguments]`
- ใช้ `Test Teardown` ปิด browser แม้กรณี test ล้มเหลว
- ใช้ explicit wait ของ SeleniumLibrary แทนการหน่วงตายตัว
- เก็บข้อมูลที่เปลี่ยนบ่อยใน variables หรือ resource/configuration file
