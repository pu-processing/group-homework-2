import ddf.minim.*;
Minim minim;//宣告
AudioPlayer in,boom;//宣告
float x,y,x_1,y_1,x_2,y_2;
float boomH,boomX,boomY,boomR,boomSpeedX,boomSpeedY;
int txtNum,pbNum;
int[][] blockXY;
int[] blockR,randN,tempN;
boolean isBoom;
int size;
int i,j,tempi,life,score;
float dist;
String str1;
String[] lines;

void pointdis(float x_1,float y_1,float x_2,float y_2){
  dist=sqrt(sq(x_1-x_2)+sq(y_1-y_2));
}

void reSetPb(){
  blockXY = new int[4][2];
  blockR = new int[4];
  tempN = new int[4];
  randN = new int[4];
  for (i = 0; i < 4; i++) {
    lines = loadStrings("list.txt");
    txtNum=lines.length/5;
    pbNum=int(random(txtNum));
    blockR[i]=size*2;
    blockXY[i][0]=int(random(blockR[i],width-blockR[i]));
    for (j=0;j<i;j++){
      if(abs(blockXY[i][0]-blockXY[j][0])<size*2){
        blockXY[i][0]=int(random(blockR[i],width-blockR[i]));
        i=0;
      }
    }
    blockXY[i][1]=blockR[i];
    tempN[i]=i+1;
  }
  for (i=0;i<4;i++){
    j=int(random(tempN.length));
    while(tempN[j]==0){
      j=int(random(tempN.length));
    }
    randN[i]=tempN[j];
    tempN[j]=0;
  }
}

void setup() {
  PFont font = createFont("標楷體", 16);
  textFont(font);
  
  size(1024,512);
  background(128);
  boomH=20;
  boomR=15;
  isBoom=false;
  x_1=width/2;
  y_1=height-2*boomH;
  x_2=mouseX;
  y_2=mouseY;
  size=15;
  reSetPb();
  tempi=0;
  life=txtNum;
  score=0;
  //背景音樂
  minim = new Minim(this);
  in = minim.loadFile("001.mp3");
  boom = minim.loadFile("boom.mp3");
  //in.setVolume(0.5);
  in.loop(); //音樂開啟
  //boom.setVolume(1);
  boom.loop();
  boom.pause();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    boom.rewind();
    boom.play();
    isBoom=true;
  }else if (mouseButton == RIGHT) {
    reSetPb();
    tempi=0;
    isBoom=false;
    score-=5;
  }
}
void draw() {
  background(128);
  y=height-2*boomH-50;
  x=(y*(x_1-x_2)-(x_1*y_2-x_2*y_1))/(y_1-y_2);
  //匯入題目
  str1=lines[pbNum*5];
  textSize(size*2);
  fill(0);
  text(str1, x_1-textWidth(str1)/2,height-10*boomH);
  strokeWeight(10);
  line(x_1, y_1, x, y);
  strokeWeight(1);
  fill(255);
  square(width/2-boomH/2,height-2*boomH, boomH);
  //結束匯入
  //匯入答案區，偵測是否正確
  if (isBoom){
    fill(255);
    circle(boomX,boomY, boomR);
    for (i = 0; i < 4; i++) {
      pointdis(boomX,boomY,blockXY[i][0],blockXY[i][1]);
      if (dist<(boomR+blockR[i])/2){
         blockR[i]=0;
         blockXY[i][0]=width;
         blockXY[i][1]=height;
         lines[i+1]="";
         isBoom=false;
         if (i==tempi){
           tempi=0;
           textSize(size*2);
           score+=10;
           str1="正確";
           text(str1,width/2-textWidth(str1)/2,height/2);
           isBoom=false;
           life--;
           reSetPb();
         }else{
           textSize(size*2);
           score-=5;
           str1="錯誤";
           text(str1,width/2-textWidth(str1)/2,height/2);
           isBoom=false;
         }
         break;
      }
    }
    if (boomY<boomR/2){
      isBoom=false;
    }
    if (boomX<boomR/2 || boomX>width-boomR/2){
      boomSpeedX=-boomSpeedX;
    }
    boomX=boomX+boomSpeedX;
    boomY=boomY+boomSpeedY;
  }else{
    x_2=mouseX;
    y_2=mouseY;
    boomSpeedX=(x-x_1)/10;
    boomSpeedY=(y-y_1)/10;
    boomX=x;
    boomY=y;
    fill(255);
    circle(boomX,boomY, boomR);
  }
  //結束匯入答案
  
  for (i = 0; i < 4; i++) {
    fill(200,100,0);
    circle(blockXY[i][0],blockXY[i][1], blockR[i]);
    line(blockXY[i][0],blockXY[i][1]+blockR[i]/2,blockXY[i][0],blockXY[i][1]+randN[i]*blockR[i]);
    fill(100,200,0);
    ellipse(blockXY[i][0],blockXY[i][1]+randN[i]*blockR[i], blockR[i]*5,blockR[i]);
    str1=lines[pbNum*5+(i+1)];
    //str1=""+i;
    textSize(size);
    fill(0);
    text(str1, blockXY[i][0]-textWidth(str1)/2, blockXY[i][1]+size/2+randN[i]*blockR[i]);
  }
  str1="左鍵發射(答對加10分，錯一次扣5分)";
  textSize(size);
  fill(255);
  rect(textWidth(str1)/2, height/2-size*1.5, textWidth(str1), size*1.5);
  fill(0);
  text(str1, textWidth(str1)/2, height/2-size/2);
  str1="右鍵下一題(扣5分)";
  textSize(size);
  fill(255);
  rect(width-1.5*textWidth(str1), height/2-size*1.5, textWidth(str1), size*1.5);
  fill(0);
  text(str1, width-1.5*textWidth(str1), height/2-size/2);
  str1="剩餘題數:"+life;
  textSize(size);
  fill(0);
  text(str1, textWidth(str1)/2, height-size/2);
  str1="分數:"+score;
  textSize(size);
  fill(0);
  text(str1, width-1.5*textWidth(str1), height-size/2);
}

void stop(){
  in.close();//音樂停止
  boom.close();
  minim.stop();
  super.stop();
}
