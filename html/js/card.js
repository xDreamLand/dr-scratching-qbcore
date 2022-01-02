var debugMode = false;
var resourceName, toFillInPercentage, win_message, lose_message, currency, key, price, price_type, price_label, formattedPrice;

$(function() {
  window.addEventListener('message', function(event) {
    if (event.data.type === "openScratch") {
      $('body').fadeIn(500);
      debugMode = event.data.debug;
      resourceName = event.data.resourceName;
      toFillInPercentage = event.data.scratchAmount;
      win_message = event.data.win_message;
      lose_message = event.data.lose_message;
      currency = event.data.currency;
      key = event.data.key;
      price = event.data.price;
      amount = event.data.amount;
      price_type = event.data.price_type;
      price_label = event.data.price_label;
      document.getElementById('key-hidden').innerHTML = key;
      document.getElementById('price-hidden').innerHTML = price;
      document.getElementById('amount-hidden').innerHTML = amount;
      document.getElementById('price-type-hidden').innerHTML = price_type;
      if(price_type == 'money') {
        formattedPrice = currency + ' ' + Number.parseFloat(price).toFixed(0); // Want decimals? Change 0 -> n of decimals
        price > 0 ? document.getElementById('price').innerHTML = "<span style='color:#2ECC71'>" + win_message + "</span><br><br><span style='font-size:50px;'>" + formattedPrice + '</span>' : document.getElementById('price').innerHTML = "<span style='color:#B2BABB;text-transform:uppercase;'>" + lose_message + "</span><br><br><span style='font-size:60px;'>" + currency + " 0</span>";
      } else {
        document.getElementById('price').innerHTML = "<span style='color:#2ECC71'>" + win_message + "</span><br><span style='font-size:20px;color:#7F8C8D'>" + amount + "x</span><br><span style='font-size:40px;'>" + price_label + '</span>'
      }
    } else if (event.data.type === "closeScratch") {
      $('body').fadeOut(500);
    }
  });
});

var isDrawing, lastPoint;
var canvas = document.getElementById('canvas'),
  ctx = canvas.getContext('2d'),
  canvasWidth = canvas.width,
  canvasHeight= canvas.height,
  image = new Image(),
  imageSrc = 'img/scratch-here.jpg',
  brush = new Image();
image.src = imageSrc;

image.onload = function() {
  ctx.drawImage(
    image,
    canvas.width / 2 - image.width / 2,
    canvas.height / 2 - image.height / 2
  );
};

brush.src = 'img/scratch.png';
canvas.addEventListener('mousedown', handleMouseDown, false);
canvas.addEventListener('touchstart', handleMouseDown, false);
canvas.addEventListener('mousemove', handleMouseMove, false);
canvas.addEventListener('touchmove', handleMouseMove, false);
canvas.addEventListener('mouseup', handleMouseUp, false);
canvas.addEventListener('touchend', handleMouseUp, false);

function distanceBetween(point1, point2) {
  return Math.sqrt(Math.pow(point2.x - point1.x, 2) + Math.pow(point2.y - point1.y, 2));
}

function angleBetween(point1, point2) {
  return Math.atan2(point2.x - point1.x, point2.y - point1.y);
}

function getFilledInPixels(stride) {
  if (!stride || stride < 1) { stride = 1; }
  var pixels = ctx.getImageData(0, 0, canvasWidth, canvasHeight),
    pdata = pixels.data,
    l = pdata.length,
    total = (l / stride),
    count = 0;
  for (var i = count = 0; i < l; i += stride) {
    if (parseInt(pdata[i]) === 0) {
      count++;
    }
  }
  return Math.round((count / total) * 100);
}

function getMouse(e, canvas) {
  var offsetX = 0,
      offsetY = 0,
      mx, my;
  if (canvas.offsetParent !== undefined) {
    do {
      offsetX += canvas.offsetLeft;
      offsetY += canvas.offsetTop;
    } while ((canvas = canvas.offsetParent));
  }
  mx = (e.pageX || e.touches[0].clientX) - offsetX;
  my = (e.pageY || e.touches[0].clientY) - offsetY;
  return { x: mx, y: my };
}

function handlePercentage(filledInPixels) {
  filledInPixels = filledInPixels || 0;
  debugMode == true ? console.log(filledInPixels + '%') : '';
  if (filledInPixels > toFillInPercentage) {
    try { canvas.parentNode.removeChild(canvas); } catch (err) {}
    var keyHtml = document.getElementById('key-hidden').innerHTML,
      priceHtml = document.getElementById('price-hidden').innerHTML,
     amountHtml = document.getElementById('amount-hidden').innerHTML,
     typeHtml = document.getElementById('price-type-hidden').innerHTML;
    $.post('https://' + resourceName + '/deposit', JSON.stringify({
      key: keyHtml,
      price: priceHtml,
      amount: amountHtml,
      type: typeHtml
    }));
  }
}

function handleMouseDown(e) {
    isDrawing = true;
    lastPoint = getMouse(e, canvas);
}

function handleMouseMove(e) {
  if (!isDrawing) { return; }
  e.preventDefault();
  var currentPoint = getMouse(e, canvas),
    dist = distanceBetween(lastPoint, currentPoint),
    angle = angleBetween(lastPoint, currentPoint),
    x, y;
  for (var i = 0; i < dist; i++) {
    x = lastPoint.x + (Math.sin(angle) * i) - 25;
    y = lastPoint.y + (Math.cos(angle) * i) - 25;
    ctx.globalCompositeOperation = 'destination-out';
    ctx.drawImage(brush, x, y);
  }
  lastPoint = currentPoint;
  handlePercentage(getFilledInPixels(32));
}

function handleMouseUp(e) {
  isDrawing = false;
}

$(document).on('keyup', function(data) {
  if (data.which == 27) {
    $.post('https://' + resourceName + '/nuiCloseCard',JSON.stringify({
      key: key,
      price: price,
      amount: amount,
      type: price_type
    }));
    window.location.reload();
  }
})