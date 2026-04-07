import asyncio
import nodriver as uc

async def main():
    # Create a new Chrome instance
    chrome = await uc.start(
        headless=False,
        browser_executable_path="/home/vugia/Downloads/chrome-lin/chrome"
    )
    
    # New page
    page = await chrome.new_page()
    
    # Navigate to the URL, ignoring TLS errors
    await page.goto("https://192.168.1.1", ignore_https_errors=True)
    
    # Fill in the username and password
    await page.fill("#txt_Username", "admin")
    await page.fill("#txt_Password", "h33A$2gvj2gr4U7avic9MQGF849r")
    
    # Click the login button, assuming it has the text "Login"
    # You might need to adjust the selector based on the actual HTML of the page
    await page.click("text=Login")
    
    # Keep the browser open for 10 seconds to see the result
    await asyncio.sleep(10)
    
    # Close the browser
    await chrome.close()

# Run the main function
asyncio.run(main())
