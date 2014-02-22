var SVG_NS = 'http://www.w3.org/2000/svg';
var XLINK_NS = 'http://www.w3.org/1999/xlink';

var oldTime = 0;
var frameTimes = 0;
var frameCount = 0;
var countFrame = 0;

function init(fps) {
	prepareFrameArray();
	setInterval(render, Math.floor(1000/fps) | 33);
}

function render() {
	if(oldTime > 0) {
		var t = new Date().getTime();
		var diff = t - oldTime;
		frameTimes += diff;
		if(++frameCount == 20) {
			var debug = document.getElementById('debug');
			debug.replaceChild(document.createTextNode(Math.round(1000 / (frameTimes / 20)) + " fps"), debug.firstChild);
			frameTimes = 0;
			frameCount = 0;
		}
	}
	oldTime = new Date().getTime();
	var frag = document.createDocumentFragment();
	countFrame++;
	buildDisplayList(frag, mcs.root);
	var el = document.getElementById('timeline');
	while(el.firstChild) { el.removeChild(el.firstChild); }
	el.appendChild(frag);
}

function buildDisplayList(parent, mc) {
	if(mc.countFrame != countFrame) {
		if(++mc.currentFrame >= mc.frames.length) { mc.currentFrame = 0; }
		mc.countFrame = countFrame;
	}
	var charArr = mc.frames[mc.currentFrame],
		charArrLen = charArr.length,
		i = 0,
		char,
		attr,
		el;
	do {
		char = charArr[i];
		if(char) {
			if(mcs[char.id]) {
				// This is a MovieClip: Create <g> and recurse
				el = document.createElementNS(SVG_NS, 'g');
				buildDisplayList(el, mcs[char.id]);
			} else {
				el = document.createElementNS(SVG_NS, 'use');
				attr = document.createAttributeNS(XLINK_NS, 'xlink:href');
				attr.nodeValue = '#' + char.id;
				el.setAttributeNodeNS(attr);
			}
			var xfValue = "";
			if(char.x != 0 || char.y != 0) {
				xfValue += "translate(" + char.x + "," + char.y + ") ";
			}
			if(char.r != 0) {
				xfValue += "rotate(" + char.r + ") ";
			}
			if(char.sx != 1 || char.sy != 1) {
				xfValue += "scale(" + char.sx + "," + char.sy + ") ";
			}
			if(xfValue != "") {
				attr = document.createAttribute('transform');
				attr.nodeValue = xfValue;
				el.setAttributeNode(attr);
			}
			parent.appendChild(el);
		}
	} while(++i < charArrLen);
}

function prepareFrameArray() {
	for(var mc in mcs) {
		mcs[mc].currentFrame = -1;
		mcs[mc].countFrame = -1;
		var frames = mcs[mc].frames;
		var framesLen = frames.length;
		for(var i = 0; i < framesLen; i++) {
			var frame = frames[i];
			var layersLen = frame.length;
			for(var j = 0; j < layersLen; j++) {
				var layer = frame[j];
				if(layer) {
				 	if(i > 0) {
						var layerPrevFrame = frames[i-1][j];
						if(layerPrevFrame) {
							if(layer.id == undefined) { layer.id = layerPrevFrame.id; }
							if(layer.x == undefined) { layer.x = layerPrevFrame.x || 0; }
							if(layer.y == undefined) { layer.y = layerPrevFrame.y || 0; }
							if(layer.r == undefined) { layer.r = layerPrevFrame.r || 0; }
							if(layer.sx == undefined) { layer.sx = layerPrevFrame.sx || 1; }
							if(layer.sy == undefined) { layer.sy = layerPrevFrame.sy || 1; }
						} else {
							if(layer.x == undefined) { layer.x = 0; }
							if(layer.y == undefined) { layer.y = 0; }
							if(layer.r == undefined) { layer.r = 0; }
							if(layer.sx == undefined) { layer.sx = 1; }
							if(layer.sy == undefined) { layer.sy = 1; }
						}
					} else {
						if(layer.x == undefined) { layer.x = 0; }
						if(layer.y == undefined) { layer.y = 0; }
						if(layer.r == undefined) { layer.r = 0; }
						if(layer.sx == undefined) { layer.sx = 1; }
						if(layer.sy == undefined) { layer.sy = 1; }
					}
				}
			}
		}
	}
}
