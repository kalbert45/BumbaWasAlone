from godot import exposed, export
from godot import *
from numpy import loadtxt
from numpy import asarray
import numpy as np
from keras.models import load_model
from PIL import Image

@exposed
class PredictionHandler(Node2D):
	model = None
	classes = None
	
	def _ready(self):
		"""
		Called every time the node is added to the scene.
		Initialization here.
		"""
		self.model = load_model('model.h5')

		# read class names
		f = open("class_names.txt", "r")
		self.classes = f.readlines()
		f.close()
		self.classes = [c.replace('\n','').replace(' ','_') for c in self.classes]
		# load test image
		#test_image = Image.open('test2.png')
		#data = asarray(test_image)
		#new_data = np.reshape(data, (1, 28, 28, 1))
		#prediction = self.model.predict(new_data)
		#ind = (-prediction).argsort()
		#ind = ind[0][:5]
		#latex = [self.classes[x] for x in ind]
		#print(latex)
		
		# load test image
		#test_image = Image.open('test4.png')
		#data = asarray(test_image)
		#new_data = 1-(np.reshape(data, (1, 28, 28, 1)) / 255)
		#prediction = self.model.predict(new_data)
		#ind = (-prediction).argsort()
		#ind = ind[0][:5]
		#latex = [self.classes[x] for x in ind]
		#print(latex)

	
	# if drawing is inactive, space activates. if active, space creates
	# 28x28 image which model uses to predict top 5 classes
	def predict(self):
	
		#paint_node = self.get_node('Paint/PaintControl')
		#paint_node.get_picture()
		test_image = Image.open('img.png')
		# preprocess image to 26x26 b&w png
		test_image = test_image.convert("L")
		test_image = test_image.resize((26,26), resample=Image.LANCZOS)
		test_image = test_image.point(lambda x: 0 if x < 230 else 255, '1')
		# pad to 28x28
		new_image = Image.new('1', (28,28), (255))
		new_image.paste(test_image,((28-test_image.size[0])//2,(28-test_image.size[1])//2))
		new_image = new_image.convert("L")
		new_image.save('convertedimg.png', format="png")
		
		#reshape data for model
		data = asarray(new_image)
		new_data = 1-(np.reshape(data, (1, 28, 28, 1)) / 255)
		
		#get top 5 class predictions
		prediction = self.model.predict(new_data)
		ind = (-prediction).argsort()
		ind = ind[0][:5]
		latex = [self.classes[x] for x in ind]

		return str(latex)
