package scenes;

import flash.system.System;
import sample.Main;
import starling.display.QuadBatch;
import starling.textures.Texture;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.text.TextField;

class BatchBenchmarkScene extends Scene
{
	private var mStartButton:Button;
	private var mResultText:TextField;
	
	//private var mContainer:Sprite;
	private var mFrameCount:Int;
	private var mElapsed:Float;
	private var mStarted:Bool;
	private var mFailCount:Int;
	private var mWaitFrames:Int;
	
	private var activeChange:Int = 0;
	private var texture:starling.textures.Texture;
	private var quadBatch:QuadBatch;
	private var quadBatchs:Array<QuadBatch>;
	private var images:Array<Image>;
	
	public function new()
	{
		super();
		
		
		
		quadBatchs = new Array<QuadBatch>();
		
		quadBatch = new QuadBatch();
		addChild(quadBatch);
		quadBatchs.push(quadBatch);
		
		images = new Array<Image>();
		
		// the container will hold all test objects
		//mContainer = new Sprite();
		//mContainer.touchable = false; // we do not need touch events on the test objects -- 
									  // thus, it is more efficient to disable them.
		//addChildAt(mContainer, 0);
		
		mStartButton = new Button(Game.assets.getTexture("button_normal"), "Start benchmark");
		mStartButton.name = 'startBenchmark';
		mStartButton.addEventListener(Event.TRIGGERED, onStartButtonTriggered);
		mStartButton.x = Constants.CenterX - Math.floor(mStartButton.width / 2);
		mStartButton.y = 20;
		addChild(mStartButton);
		
		mStarted = false;
		mElapsed = 0.0;
		
		texture = Game.assets.getTexture("benchmark_object");
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
		
		sample.Main.mouseOnStageDispatcher.addEventListener(Event.CHANGE, OnActiveChange);
	}
	
	private function OnActiveChange(e:Event):Void 
	{
		activeChange = 0;
	}
	
	public override function dispose():Void
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		mStartButton.removeEventListener(Event.TRIGGERED, onStartButtonTriggered);
		super.dispose();
	}
	
	private function onEnterFrame(event:EnterFrameEvent):Void
	{
		if (!mStarted) return;
		
		mElapsed += event.passedTime;
		mFrameCount++;
		
		activeChange++;
		
		if (mFrameCount % mWaitFrames == 0)
		{
			var fps:Float = mWaitFrames / mElapsed;
			var targetFps:Float = Starling.current.nativeStage.frameRate;
			
			if (Math.ceil(fps) >= targetFps)
			{
				mFailCount = 0;
				if (activeChange > 10) 
					addTestObjects();
			}
			else
			{
				if (activeChange > 10) mFailCount++;
				
				if (mFailCount > 20)
					mWaitFrames = 5; // slow down creation process to be more exact
				if (mFailCount > 30)
					mWaitFrames = 10;
				if (mFailCount == 40)
					benchmarkComplete(); // target fps not reached for a while
			}
			
			mElapsed = mFrameCount = 0;
		}
		
		//var numObjects:Int = quadBatch.numQuads;
		//var numObjects:Int = mContainer.numChildren;
		var passedTime:Float = event.passedTime;
		
		var addAmount:Float = Math.PI / 2 * passedTime;
		/*for (i in 0...numObjects) {
			//quadBatch.
			mContainer.children[i].rotation += addAmount;
		}*/
		
		//quadBatch.reset();
		for (j in 0...images.length) {
			images[j].rotation += addAmount;
			quadBatch.addImage(images[j]);
			
			if (quadBatch.numQuads >= QuadBatch.MAX_NUM_QUADS) {
				quadBatch = new QuadBatch();
				addChild(quadBatch);
				quadBatchs.push(quadBatch);
			}
			//var quadBatchIndex:Int = Math.floor(quadBatch.numQuads / QuadBatch.MAX_NUM_QUADS);
			//if (j == images.length-1) trace("quadBatchIndex = " + quadBatchIndex, "j = " + j);
			//quadBatchs[quadBatchIndex].addImage(images[j]);
			
			
		}
	}
	
	private function onStartButtonTriggered():Void
	{
		mStartButton.visible = false;
		mStarted = true;
		mFailCount = 0;
		mWaitFrames = 2;
		mFrameCount = 0;
		
		if (mResultText != null) 
		{
			mResultText.removeFromParent(true);
			mResultText = null;
		}
		
		addTestObjects();
	}
	
	private function addTestObjects():Void
	{
		var padding:Int = 15;
		var numObjects:Int = mFailCount > 20 ? 1 : 5;
		
		
		
		for (i in 0...numObjects)
		{
			var egg:Image = new Image(texture);
			egg.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
			egg.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);
			egg.touchable = false;
			//mContainer.addChild(egg);
			//quadBatch.addImage(egg);
			images.push(egg);
		}
	}
	
	private function benchmarkComplete():Void
	{
		mStarted = false;
		mStartButton.visible = true;
		
		var fps:Int = cast Starling.current.nativeStage.frameRate;
		
		var total:Int = 0;
		for (i in 0...quadBatchs.length) 
		{
			total += quadBatchs[i].numQuads;
		}
		trace("Benchmark complete!");
		trace("FPS: " + fps);
		trace("Float of objects: " + total);
		
		var resultString:String = "Result:\n" + total + " objects\nwith " + fps + " fps";
		mResultText = new TextField(240, 200, resultString);
		mResultText.fontSize = 30;
		mResultText.x = Constants.CenterX - mResultText.width / 2;
		mResultText.y = Constants.CenterY - mResultText.height / 2;
		
		addChild(mResultText);
		
		//mContainer.removeChildren();
		#if flash
			System.pauseForGCIfCollectionImminent();
		#end
		
	}	
}