import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.Lib;
import openfl.geom.Rectangle;
import openfl.filters.GlowFilter;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BitmapFilter;
import openfl.display.BitmapData;

class Main extends Sprite {

    public function new() {
        super();
        var bitmapData = Assets.getBitmapData('assets/pearl.png');
        addBitmap(bitmapData, new Rectangle(0, 0, stage.stageWidth/2, stage.stageHeight), []);
        addBitmap(bitmapData, new Rectangle(stage.stageWidth/2, 0, stage.stageWidth/2, stage.stageHeight), [
            new GlowFilter(0x000000, 1, 15, 15, 10, BitmapFilterQuality.LOW, false, false)
        ]);
    }

    private function addBitmap(data:BitmapData, rect:Rectangle, filters:Array<BitmapFilter>):Void {
        var sprite = new Sprite();
        sprite.x = rect.x;
        sprite.y = rect.y;
        addChild(sprite);
        var bitmap = new Bitmap(data);
        bitmap.x = -bitmap.width / 2;
        bitmap.y = -bitmap.height / 2;
        bitmap.filters = filters;
        sprite.addChild(bitmap);
        function cameraTo(x:Float, y:Float) {
            var scrollRect:Rectangle = new Rectangle(
                x - rect.width / 2,
                y - rect.height / 2,
                rect.width,
                rect.height);
            sprite.scrollRect = scrollRect;
        }
        function onEnterFrame(event:Event):Void {
            var t = Lib.getTimer() / 1000 * Math.PI * 2;
            var d = 100;
            cameraTo(Math.cos(t) * d, Math.sin(t) * d);
        }
        cameraTo(0, 0);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

}
