*** Settings ***
Library    SeleniumLibrary
Test Teardown    Close All Browsers

*** Variables ***
${BASE_URL}    https://www.saucedemo.com
${USERNAME}    standard_user
${PASSWORD}    secret_sauce
${FIRST_NAME}    Somchai
${LAST_NAME}    Testing
${POSTAL_CODE}    10110

*** Test Cases ***
Complete SauceDemo Purchase
    Open SauceDemo And Login
    Location Should Be    ${BASE_URL}/inventory.html
    Sort Products By Price High To Low
    Verify First Two Prices Are Descending
    Add Most Expensive And Cheapest Products
    Open Cart
    Open Checkout Information
    Enter Checkout Information
    Verify Checkout Totals
    Finish Order

*** Keywords ***
Open SauceDemo And Login
    Open Browser    ${BASE_URL}    chrome
    Input Text    id:user-name    ${USERNAME}
    Input Password    id:password    ${PASSWORD}
    Click Button    id:login-button

Sort Products By Price High To Low
    Select From List By Label    css:select[data-test="product-sort-container"]    Price (high to low)

Verify First Two Prices Are Descending
    ${first_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item-price"])[1]
    ${second_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item-price"])[2]
    ${first_price}=    Evaluate    float($first_price_text.replace("$", ""))
    ${second_price}=    Evaluate    float($second_price_text.replace("$", ""))
    Log    First two prices after sorting: ${first_price_text}, ${second_price_text}
    Should Be True    ${first_price} >= ${second_price}

Add Most Expensive And Cheapest Products
    ${highest_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item"])[1]//*[@data-test="inventory-item-price"]
    ${lowest_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item"])[last()]//*[@data-test="inventory-item-price"]
    Log    Selecting highest ${highest_price_text} and lowest ${lowest_price_text}
    Click Element    xpath:(//*[@data-test="inventory-item"])[1]//button
    Click Element    xpath:(//*[@data-test="inventory-item"])[last()]//button
    Wait Until Element Is Visible    css:[data-test="shopping-cart-badge"]
    Element Text Should Be    css:[data-test="shopping-cart-badge"]    2

Open Cart
    Click Element    css:[data-test="shopping-cart-link"]
    ${cart_item_count}=    Get Element Count    css:[data-test="cart-list"] [data-test="inventory-item"]
    Should Be Equal As Integers    ${cart_item_count}  2

Open Checkout Information
    Click Element    xpath://*[@id="checkout"]

Enter Checkout Information
    Input Text    id:first-name    ${FIRST_NAME}
    Input Text    id:last-name    ${LAST_NAME}
    Input Text    id:postal-code    ${POSTAL_CODE}
    Textfield Value Should Be    id:postal-code    ${POSTAL_CODE}
    Click Element    xpath://*[@id="continue"]
    Wait Until Page Contains    Checkout: Overview    10s

Verify Checkout Totals
    ${first_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item-price"])[1]
    ${second_price_text}=    Get Text    xpath:(//*[@data-test="inventory-item-price"])[2]
    ${subtotal_text}=    Get Text    css:[data-test="subtotal-label"]
    ${tax_text}=    Get Text    css:[data-test="tax-label"]
    ${total_text}=    Get Text    css:[data-test="total-label"]

    ${calculated_item_total}=    Evaluate    round(float($first_price_text.replace("$", "")) + float($second_price_text.replace("$", "")), 2)
    ${displayed_item_total}=    Evaluate    float($subtotal_text.split("$")[1])
    Should Be Equal As Numbers    ${calculated_item_total}    ${displayed_item_total}    precision=2

    ${expected_tax}=    Evaluate    round($calculated_item_total * 0.08, 2)
    ${displayed_tax}=    Evaluate    float($tax_text.split("$")[1])
    Should Be Equal As Numbers    ${expected_tax}    ${displayed_tax}    precision=2

    ${calculated_total}=    Evaluate    round($calculated_item_total + $displayed_tax, 2)
    ${displayed_total}=    Evaluate    float($total_text.split("$")[1])
    Should Be Equal As Numbers    ${calculated_total}    ${displayed_total}    precision=2

    Log    Item total: ${displayed_item_total}; Tax: ${displayed_tax}; Total: ${displayed_total}

Finish Order
    Click Element    id:finish
    Wait Until Element Is Visible    class:complete-header    10s
    Element Text Should Be    class:complete-header    Thank you for your order!
    Location Should Be    ${BASE_URL}/checkout-complete.html