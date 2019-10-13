from PIL import Image

image = Image.open("walk.png")

print(image)

minimum_dimension = min(image.size)

if image.size[0] < image.size[1]:
    for i in range(image.size[1]//image.size[0]):
        cropped_image = image.crop(box=(0, i * minimum_dimension, minimum_dimension, i * minimum_dimension + minimum_dimension))
        cropped_image.save("walk_{}.png".format(i))
else:
    for i in range(image.size[0]//image.size[1]):
        box=(i * minimum_dimension, 0, i * minimum_dimension + minimum_dimension, minimum_dimension)
        print(box)
        cropped_image = image.crop(box=box)
        cropped_image.save("walk_{}.png".format(i))
