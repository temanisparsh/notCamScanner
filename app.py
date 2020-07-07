from flask import Flask, render_template , request , jsonify, Response, send_file
from PIL import Image
import jsonpickle

import os , io , sys
import numpy as np 
import cv2
import base64

from croppedImage import croppedImage, exportImages

app = Flask(__name__)

@app.route('/getBounded' , methods=['POST'])
def mask_image():
    image = base64.b64decode(request.json['image'])

    with open("test.jpg", "wb") as out_file:
        out_file.write(image)

    # res_image = croppedImage('test.jpg')
    res_image = cv2.imread('test.jpg')

    img = Image.fromarray(res_image.astype("uint8"))

    rawBytes = io.BytesIO()
    img.save(rawBytes, "JPEG")
    rawBytes.seek(0)
    img_base64 = base64.b64encode(rawBytes.read()).decode('utf-8')

    return img_base64

@app.route('/getExport' , methods=['POST'])
def export_image():

    exportImages(request.json['images'])

    res_image = cv2.imread('croppedtest.jpg')

    img = Image.fromarray(res_image.astype("uint8"))

    rawBytes = io.BytesIO()
    img.save(rawBytes, "JPEG")
    rawBytes.seek(0)
    img_base64 = base64.b64encode(rawBytes.read()).decode('utf-8')

    return img_base64

if __name__ == '__main__':
	app.run(debug = True)
