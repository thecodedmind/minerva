import minerva

var m = newMarkov()
#[]
m.feed "this is a test"
m.feed "this is an orange"
m.feed "this is a tomato"
m.feed "what is a cucumber"
m.feed "where is a carrot"
m.feed "i am an orange and you are a tomato"
]#
m.read "/home/kaiz0r/Downloads/discord_dataset_2.txt"
echo m.generate()
