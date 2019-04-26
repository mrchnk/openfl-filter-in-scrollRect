import openfl.Lib;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;

class Main extends Sprite {

    private var filter:BitmapFilter;

    public function new() {
        super();
        var bitmapData = Assets.getBitmapData('assets/pearl.png');

        filter = new GlowFilter(0, 1, 15, 15, 10, BitmapFilterQuality.LOW, false, false);

        function bitmapFactory():DisplayObject {
            return new Bitmap(bitmapData);
        }

        function shapeFactory():DisplayObject {
            var shape:Shape = new Shape();
            shape.graphics.beginFill(0xff0000, 1);
            shape.graphics.drawCircle(40, 40, 40);
            shape.graphics.endFill();
            return shape;
        }

        function complexFactory():DisplayObject {
            var complex:Sprite = new Sprite();
            var bitmap:Bitmap = new Bitmap(bitmapData);
            complex.addChild(bitmap);
            var shape:Shape = new Shape();
            shape.graphics.beginFill(0x00ff00, 0.5);
            shape.graphics.drawEllipse(bitmap.width/2, bitmap.height/2, bitmap.width, bitmap.height);
            complex.addChild(shape);
            return complex;
        }

        var areas = cut(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));

        addTest(areas.topLeft, bitmapFactory);
        addTest(areas.topRight, shapeFactory);
        addTest(areas.bottomLeft, complexFactory);
    }

    private function addTest(rect:Rectangle, factory:Void->DisplayObject) {
        var shape:Sprite = new Sprite();
        var areas = cut(rect);

        addArea(areas.topLeft, factory, filter, function (sprite:Sprite, child:DisplayObject, rect:Rectangle):Void {
            sprite.addChild(shape);
            shape.graphics.clear();
            shape.graphics.lineStyle(1, 0xff0000, 1, false);
            shape.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        });


        addArea(areas.topRight, factory, null, function (sprite:Sprite, child:DisplayObject, rect:Rectangle):Void {
            sprite.scrollRect = rect;
        });

        addArea(areas.bottomLeft, factory, filter, function (sprite:Sprite, child:DisplayObject, rect:Rectangle):Void {
            sprite.scrollRect = rect;
        });

        addArea(areas.bottomRight, factory, filter, function (sprite:Sprite, child:DisplayObject, rect:Rectangle):Void {
            child.x = 0;
            child.y = 0;
            rect.offset(-rect.width + child.width/2, -rect.height + child.height/2);
            child.scrollRect = rect;
        });

    }

    private function cut(rect:Rectangle):{ topLeft:Rectangle, topRight:Rectangle, bottomLeft:Rectangle, bottomRight:Rectangle } {
        var halfWidth:Float = rect.width / 2;
        var halfHeight:Float = rect.height / 2;

        function rectAt(x, y):Rectangle {
            return new Rectangle(
                x + rect.x,
                y + rect.y,
                halfWidth,
                halfHeight
            );
        }

        return {
            topLeft: rectAt(0, 0),
            topRight: rectAt(halfWidth, 0),
            bottomLeft: rectAt(0, halfHeight),
            bottomRight: rectAt(halfWidth, halfHeight)
        }
    }

    private function addArea(rect:Rectangle, factory:Void->DisplayObject, filter:BitmapFilter, setRect:Sprite->DisplayObject->Rectangle->Void):Void {
        var sprite = new Sprite();
        sprite.x = rect.x;
        sprite.y = rect.y;
        addChild(sprite);

        var child = factory();
        child.x = rect.width / 2 - child.width / 2;
        child.y = rect.height / 2 - child.height / 2;
        child.filters = filter == null ? [] : [filter];
        sprite.addChild(child);

        function cameraTo(x:Float, y:Float) {
            var scrollRect:Rectangle = new Rectangle(
                x + rect.width / 4,
                y + rect.height / 4,
                rect.width / 2,
                rect.height / 2);
            setRect(sprite, child, scrollRect);
        }

        function onEnterFrame(event:Event):Void {
            var t = Lib.getTimer() / 5000 * Math.PI * 2;
            cameraTo(Math.cos(t) * rect.width/4, Math.sin(t) * rect.height/4);
        }

        cameraTo(0, 0);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

}
