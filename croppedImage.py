from skimage.filters import threshold_local
import cv2
import imutils
import base64
import numpy as np
    
def order_points(pts):
	rect = np.zeros((4, 2), dtype = "float32")

	s = pts.sum(axis = 1)
	rect[0] = pts[np.argmin(s)]
	rect[2] = pts[np.argmax(s)]

	diff = np.diff(pts, axis = 1)
	rect[1] = pts[np.argmin(diff)]
	rect[3] = pts[np.argmax(diff)]

	return rect

def four_point_transform(image, pts):
	rect = order_points(pts)
	(tl, tr, br, bl) = rect

	widthA = np.sqrt(((br[0] - bl[0]) ** 2) + ((br[1] - bl[1]) ** 2))
	widthB = np.sqrt(((tr[0] - tl[0]) ** 2) + ((tr[1] - tl[1]) ** 2))
	maxWidth = max(int(widthA), int(widthB))

	heightA = np.sqrt(((tr[0] - br[0]) ** 2) + ((tr[1] - br[1]) ** 2))
	heightB = np.sqrt(((tl[0] - bl[0]) ** 2) + ((tl[1] - bl[1]) ** 2))
	maxHeight = max(int(heightA), int(heightB))

	dst = np.array([
		[0, 0],
		[maxWidth - 1, 0],
		[maxWidth - 1, maxHeight - 1],
		[0, maxHeight - 1]], dtype = "float32")

	M = cv2.getPerspectiveTransform(rect, dst)
	warped = cv2.warpPerspective(image, M, (maxWidth, maxHeight))

	return warped
    
def croppedImage(imagePath):
    # read the image and clone the original image
    image = cv2.imread(imagePath)
    orig = image.copy()
    
    # compute the ratio of old height to new height and resize the image
    ratio = image.shape[0] / 500.0
    image = imutils.resize(image, height = 500)
    
    # convert the image to grayscale, blur it and find the edges
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (5, 5), 0)
    edged = cv2.Canny(gray, 75, 200)
    
    # find the contours in the edged image, keeping only the largest five
    cnts = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)
    cnts = sorted(cnts, key = cv2.contourArea, reverse = True)[:5]
    
    # loop through all the contours
    for c in cnts:
        # approximate the contour
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)

    	# if our approximated contour has four points, then we can assume that we have found our screen
        if len(approx) == 4:
            screenCnt = approx
            break    
        
    # apply the four point transform to obtain a top-down view of the original image
    warped = four_point_transform(orig, screenCnt.reshape(4, 2) * ratio)
    
    # convert the warped image to grayscale, then threshold it to give it that 'black and white' paper effect
    warped = cv2.cvtColor(warped, cv2.COLOR_BGR2GRAY)
    T = threshold_local(warped, 11, offset = 10, method = "gaussian")
    warped = (warped > T).astype("uint8") * 255
    
    # resize the warped image
    warped = imutils.resize(warped, height = 650)
    
    # return the warped image
    return warped

def exportImages(images):

    for i in range(len(images)):
        images[i] = base64.b64decode(images[i])

        with open("test.jpg", "wb") as out_file:
            out_file.write(images[i])

        images[i] = cv2.imread('test.jpg')

        images[i] = cv2.cvtColor(images[i], cv2.COLOR_BGR2GRAY)
        T = threshold_local(images[i], 11, offset = 10, method = "gaussian")
        images[i] = (images[i] > T).astype("uint8") * 255

    def vconcat_resize_min(im_list, interpolation=cv2.INTER_CUBIC):
        w_min = min(im.shape[1] for im in im_list)
        im_list_resize = [cv2.resize(im, (w_min, int(im.shape[0] * w_min / im.shape[1])), interpolation=interpolation)
                        for im in im_list]
        return cv2.vconcat(im_list_resize)

    imgs_comb = vconcat_resize_min(images)

    cv2.imwrite('croppedtest.jpg', imgs_comb)