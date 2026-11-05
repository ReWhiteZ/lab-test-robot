# Lab 03 — Robot Framework และ SeleniumLibrary

คู่มือสร้างโปรเจกต์ Robot Framework ที่ใช้ SeleniumLibrary ตั้งแต่เริ่มต้น และอธิบายรูปแบบการเขียน test ด้วย Robot Framework โดยไม่ยึดกับโจทย์เฉพาะหน้าเว็บใด

## สิ่งที่ต้องมี

- Python 3.14 (โปรเจกต์นี้กำหนด `requires-python = ">=3.14"`)
- `uv` สำหรับสร้าง virtual environment และติดตั้งแพ็กเกจ
- Google Chrome หรือ Chromium

ตรวจสอบเครื่องมือด้วย `python --version` และ `uv --version` หลังติดตั้ง `uv` จากเอกสารทางการ Selenium Manager ของ SeleniumLibrary ช่วยจัดหา WebDriver อัตโนมัติในกรณีทั่วไป

## สร้างโปรเจกต์จากศูนย์

```cmd
mkdir robot-selenium-tests
cd /d robot-selenium-tests
uv init
uv add robotframework==7.5 robotframework-seleniumlibrary
mkdir tests
mkdir results
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

```cmd
uv sync
uv run robot --outputdir results tests
```

รันไฟล์เดียวได้ด้วย:

```cmd
uv run robot --outputdir results tests/saucedemo.robot
```

เปิด `results/report.html` เพื่อดูสรุป และ `results/log.html` เพื่อดูขั้นตอนและ keyword ที่ทำงาน หากต้องการใช้ Chrome แบบ headless ให้ตั้งค่า options ใน `Open Browser` หรือกำหนดค่าผ่าน variable/configuration ให้เหมาะกับโปรเจกต์

## แนวทางที่ควรทำ

- ใช้ keyword ระดับสูงที่อ่านแล้วเข้าใจขั้นตอน test ได้
- รวมการทำซ้ำเป็น keyword และพารามิเตอร์ด้วย `[Arguments]`
- ใช้ `Test Teardown` ปิด browser แม้กรณี test ล้มเหลว
- ใช้ explicit wait ของ SeleniumLibrary แทนการหน่วงตายตัว
- เก็บข้อมูลที่เปลี่ยนบ่อยใน variables หรือ resource/configuration file

## เปิดดูระหว่างสอบ: ทางลัดและภาพรวมไฟล์นี้

ให้จำโครงสร้าง Robot เป็น **Settings → Variables → Test Cases → Keywords**. Test case บอกลำดับงานด้วยชื่อ keyword; keyword ซ่อนขั้นตอนย่อยและรับค่าผ่าน `[Arguments]`. แต่ละคอลัมน์คั่นด้วยช่องว่างอย่างน้อยสองช่อง และ `${name}` คือ scalar variable

ไฟล์ `tests/saucedemo.robot` มี test case `Complete SauceDemo Purchase` เพียงกรณีเดียว โดยเรียก keyword สำหรับ login, sort, ตรวจราคา, เพิ่มสินค้า, checkout, ตรวจยอด และยืนยันคำสั่งซื้อ จุดสำคัญคือ test case อ่านเป็น workflow ส่วนรายละเอียด Selenium อยู่ใน user keywords ด้านล่าง

### คำสั่งที่ใช้บ่อย

```cmd
uv sync                                           # ติดตั้ง dependencies จาก lockfile
uv run robot --outputdir results tests            # รันทุก test ใน tests/
uv run robot --outputdir results tests/saucedemo.robot  # รันไฟล์เดียว
```

ผลลัพธ์หลักคือ `results/report.html`, `results/log.html` และ `results/output.xml`. ใช้ `--test "ชื่อ Test"` เพื่อเลือก test case หรือ `--include tag` หากกำหนด tag ไว้

### เมื่อเจอปัญหา

- Robot หา keyword ไม่เจอ: ตรวจว่า import Library/Resource ใน Settings และสะกดชื่อ keyword ถูก
- keyword หา element ไม่เจอ: ตรวจ locator และใช้ `Wait Until Element Is Visible` ก่อน action
- test fail แล้ว browser ยังเปิด: กำหนด `Test Teardown    Close All Browsers`
- ดูขั้นตอนที่ fail: เปิด `log.html` แล้วตรวจ keyword, locator และข้อความ error ในจุดนั้น

### เอกสารอ้างอิงขณะสอบ

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework: Writing your first test](https://docs.robotframework.org/docs/getting_started/how_to_write_rf)
- [SeleniumLibrary keyword documentation](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [uv: Working on projects](https://docs.astral.sh/uv/guides/projects/)

