from faker import Faker

productIds = [707,708,711,712,714,715,716,717,718,722,738,739,742,743,747,748,779,780,781,782,783,784,792,793,794,795,796,797,798,799,800,801,808,809,810,813,822,835,836,838,858,859,860,864,865,867,868,869,870,873,874,875,876,877,880,881,883,884,885,886,889,891,892,893,894,895,896,899,900,904,905,907,908,909,910,913,916,917,918,920,924,925,926,935,936,937,938,939,940,944,945,947,948,949,951,952,953,954,955,956,957,958,959,960,961,962,963,964,965,966,967,968,969,970,971,972,973,974,975,976,977,978,979,980,981,982,983,984,985,986,987,988,989,990,991,992,993,994,996,997,998,999]


def generateClickEvent(impressionEvent):
    faker = Faker()
    click = {}
    click["clickId"] = faker.uuid4()
    click["impressionId"] = impressionEvent["impressionId"]
    click["clickDate"] = impressionEvent["impressionDate"]
    click["productId"] = impressionEvent["productId"]
    return click


def generateImpressionEvent(isUnsupportedBrowser, isAnomaly, productId):
    faker = Faker()
    impression = {}
    impression["impressionId"] = faker.uuid4()
    impression["impressionDate"] = faker.date_time_between(start_date="-1w", end_date="now").isoformat()
    if productId:
        impression["productId"] = str(productId)
    else:
        impression["productId"] = faker.random_element(productIds)

    if isUnsupportedBrowser:
        impression["browser"] = "unsupported"
    else:
        impression["browser"] = faker.random_element(["Edge", "Chrome", "Safari", "Firefox"])
    impression["browserVersion"] = faker.random_element(["10.2", "13.6", "8.6", "8.5", "11.2", "14.6", "6.6", "4.5"])
    impression["device"] = faker.random_element(["mobile", "computer", "tablet", "mobile", "computer"])
    impression["source"] = faker.random_element( ["organic", "bing", "google", "facebook"])
    impression["ip_address"] = faker.ipv4()
    impression["landing_page"] = faker.uri()
    if isAnomaly:
        impression["page_loading_seconds"] = faker.random_number(4)/100
    else:
        impression["page_loading_seconds"] = faker.random_number(4)/1000
    return impression