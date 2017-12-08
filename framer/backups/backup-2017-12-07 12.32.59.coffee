# Import file "interactive_mobile_mockup"
sketch = Framer.Importer.load("imported/interactive_mobile_mockup@2x", scale: 1)
{Firebase} = require "firebase/firebase"
firebaseRef = new Firebase
	projectID: "microjustice-demo" # ... Database → first part of URL
	secret: "DyVbwYoB3leQftI1OjZIjnMCnqGzwNftrlgBsFKf" # ... Project 

allQuestions = ["I say something at a meeting and nobody responds. A colleague says the same thing I did and everyone reacts positively.", "I’m told to be more assertive if I want to succeed.  But I’m also told that I should be likeable.", "When a colleague tells me to smile more.", "I say something and the person responds to the person who is sitting next to me.", "When a colleague explains something to me that I didn’t ask them to explain and I already know about.","Being called too aggressive when I speak and behave the same as a male colleague.", "When men take over a conversation and only go back and forth between each other when I started the conversation.", "When there’s a reference to an occupation and it uses ‘he’ as the placeholder (let’s say a researcher found this, he would then do that)","I’m talking with a group of people and someone asks: What are you ladies gossiping about?","When someone says: 'What they’re trying to say is…'","Someone looking to me and saying 'You’re taking notes, right?'", "Being asked if it’s 'that time of month'."]

allAnswers = {}

firebaseRef.onChange "/MA", (change) -> 
	if change.hasOwnProperty("counter")
		if typeof allAnswers[change.questionId] == "undefined"
			allAnswers[change.questionId] = {}
		allAnswers[change.questionId][change.optionId] = change
	else 
		allAnswers = change

		
page = new PageComponent
	width: Screen.width
	height: Screen.height
	scrollVertical: false


for txt, questionId in allQuestions
	
	currentPage = questionPage.copy()
	#currentPage.childrenWithName("questionText").text = t
	page.addPage(currentPage)
	for childLayer in currentPage.children
		childLayer.questionId = questionId
		if childLayer.name == "questionText"
			childLayer.text = txt
			
		for optionName in ["hexagon", "chevron", "triangle"]		
			if childLayer.name == optionName
				childLayer.onClick (event, clickedLayer) ->	
					try
						count = allAnswers["MA" + clickedLayer.questionId][clickedLayer.name].counter
						
					catch
						count = 0
						
					firebaseRef.put("/MA/MA"+ clickedLayer.questionId + "/" + clickedLayer.name, 
						{counter:count+1,
						questionId: "MA" + clickedLayer.questionId,
						optionId: clickedLayer.name})
						
					#add each individual poll to make adding a token to main data visualization easier
					firebaseRef.post("/answers",{questionId: "MA" + clickedLayer.questionId, optionId: clickedLayer.name})
					clickedLayer.animate
						scale: 1.42
						options:
							time: 0.22
							curve: Spring
				
flow = new FlowComponent
flow.showNext(initialPage)

startButton.onTap (event, layer) ->
	flow.showNext(page)
flow.footer = footer;


# initialPage = new PageComponent
# 	width: Screen.width
# 	height: Screen.height
# 	scrollVertical: false
