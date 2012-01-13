//
//  MainCubeBuilder.cpp
//  CubeBuilder
//
//  Created by Kris Temmerman on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "MainCubeBuilder.h"

//#define USEAO 0
void MainCubeBuilder::setup1()
{
  

    model =Model::getInstance();
    model->isDirty =true; 
    
    
    interfaceHandler =new InterfaceHandler();
    interfaceHandler->setup();
    
    makeCallBack( MainCubeBuilder,becameActive,becameActivecall );
    model->addEventListener("becameActive" ,becameActivecall);
    
    
    camera =new Camera();
    model->camera =camera;
    flatRenderer =new FlatRenderer();
    flatRenderer->setup();
    
 
   }
void MainCubeBuilder::setup2()
{
    
   
    
    
    cubeHandler =new CubeHandler();
    cubeHandler->setup();
    
    model->cubeHandler = cubeHandler;
    
    cubeRenderer =new CubeRenderer();
    cubeRenderer->setup();
    cubeRenderer->camera =camera;
    cubeRenderer->cubeHandler = cubeHandler;
    
    cubeHandler->vertexBuffer =cubeRenderer->vertexBuffer;
    cubeHandler->addCube(0,0,0);
    
    previewCube =new PreviewCube();
    previewCube->setup();
    
    cubeRenderer->previewCube  = previewCube;
    
    cubeHandler->previewCube =previewCube;
    
    
   }

void MainCubeBuilder::setup3 ()
{
    
    
       
    
    backGround  =new BackGround();
    backGround->setup();
    
    model->backGround =backGround;
    
    model->setColor(24);
    
    
    
    
    glClearColor(0.0f,0.0f, 0.0f, 0.0f);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW);
    glCullFace(GL_BACK);
    
    OpenGLErrorChek::chek("mainsetup");
    
    
    model->renderHit =true;
    backGround->isDirty =true;
    

    
    
    
  //  interfaceHandler->display.setOpen(true);
    
   
}
void MainCubeBuilder::start()
{
    npEvent *e;
    interfaceHandler->display.setAdd(e );
    interfaceHandler->display.setOpen(true);
}
void MainCubeBuilder::update ()
{
  
    npTweener::update();
   
    interfaceHandler->renderTick();

    if(camera->isDirty)
    {
        camera->update();
        cubeRenderer->isDirty =true;
    }
    if (model->useAO)
    {
        
   // cubeRenderer->isDirty =true;
   // cubeRenderer->useAO=true;
    }
    cubeHandler->update();
    if (previewCube->isDirty)cubeRenderer->isDirty =true;
    
    cubeRenderer->renderTick();
    backGround->renderTick();
     
}


void MainCubeBuilder::draw ()
{
     
    //cout << frameCount << endl;
   
    if (!cubeRenderer->isDirty && !interfaceHandler->isDirty && !backGround->isDirty && !model->isDirty)return;
    
    
    // cout << "\ndirties: "<< cubeRenderer->isDirty << " "<<interfaceHandler->isDirty << " "<<backGround->isDirty <<" " <<cubeHandler->isDirty<<"\n";
    if (model->renderHit) cubeRenderer->drawIDcubes()  ;
 
  //  glClearColor(1.0f,1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable (GL_BLEND); 
  
  
    
    flatRenderer->start();
    
   // if(!model->takeSnapshot)
   // {
    backGround->prepForFlatDraw();
    flatRenderer->draw();
  // }
    cubeRenderer->prepForFlatDraw();
    flatRenderer->draw();
#if (defined USEAO)
 

    

    if (cubeRenderer->useAO     || model->keepAO){
        model->useAO =false;
        if(!model->isIpad1)
        {
        cubeRenderer->prepForAODraw();
            flatRenderer->draw();
        
        }else
        {
            model->keepAO =false;
            cubeRenderer->useAO =false;
               cubeRenderer-> isDirty =false ;
        }
        
    }
#endif
    if(model->takeSnapshot)
    {
        
      ///  if (model->pixeldata ){ delete[]  model->pixeldata ;}
        int vpW;
        int vpH;
        if (currentorientation ==1)
        {
            vpW = 1024;
            vpH = 768;
            
        }
        else
        {
            vpH = 1024;
            vpW = 768;
        }
        GLubyte *data =(GLubyte *) malloc(768*1024*4);
        
        glReadPixels(0, 0,  vpW,vpH, GL_RGBA,GL_UNSIGNED_BYTE,data);
        
        
        
        model->pixelW= vpW;
        model->pixelH = vpH;
        model->pixeldata = data;
        model->takeSnapshot =false;
        draw ();
        
        cout <<"snap"<< (int )data[1];
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"setOverView" object:[NSNumber numberWithInt:11]]; 
        if (model->snapType==0)[[NSNotificationCenter defaultCenter] postNotificationName:@"setOverView" object:[NSNumber numberWithInt:11]]; 
         if (model->snapType==1)[[NSNotificationCenter defaultCenter] postNotificationName:@"setOverView" object:[NSNumber numberWithInt:14]]; 
       return;
    }
    
    interfaceHandler->prepForFlatDraw();
    flatRenderer->draw();
    
  
    
    flatRenderer->stop ();
      
    glDisable  (GL_BLEND); 
   // glClearColor(0.0f,0.0f, 0.0f, 0.0f);
     model->isDirty =false;
}


void MainCubeBuilder::setTouches(vector<npTouch> &touches)
{
    int currentState  = model->currentState;
    
    int mtGuestureCount =0;
    for(int i =0;i<touches.size();++i)
    {
        if(touches[i].phase ==NP_TOUCH_MOVE && touches[i].target ==NULL){mtGuestureCount++;}
    
    }
    if (mtGuestureCount >1) cout << "ROTATEMOVE WATHEVER\n";
    for(int i =0;i<touches.size();++i)
    {
        
        if(touches[i].phase ==NP_TOUCH_STOP && touches[i].target)
        {
            
          
                npTouchEvent t;
                t.name  =TOUCH_UP;
                t.target = touches[i].target;
                touches[i].target->dispatchEvent(t );
                if(t.target->isTouching(touches[i]))
                {
                    npTouchEvent ti;
                    ti.name  =TOUCH_UP_INSIDE;
                    ti.target = touches[i].target;
                    touches[i].target->dispatchEvent(ti );
                    
                }
                touches[i].target =NULL;
        }
        else if (touches[i].phase ==NP_TOUCH_START)
        {
            
            if( !interfaceHandler->checkTouch(touches[i]))
            {
               
                    if (currentState<10)
                    {
                        if(cubeRenderer->getPoint(touches[i].x,touches[i ].y))
                        {
                            cubeHandler->touchedCube(cubeRenderer->currentCubeIndex,cubeRenderer->currentCubeSide,touches[i].phase);
                            
                        } else 
                        {
                            previewCube->setPos(10000 , -10000,-10000);
                        } 
                    }
                    else  if (currentState<20)
                    {
                        
                        camera->checkTouch(touches[i]);
                        
                    }
              
            }
            
        }else///move
        {
            if(touches[i].target)
            {
                interfaceHandler->checkTouch(touches[i]);             
        
            }else
            {
            
            
            
                if (currentState<10)
                {
                    if(cubeRenderer->getPoint(touches[i].x,touches[i ].y))
                    {
                        cubeHandler->touchedCube(cubeRenderer->currentCubeIndex,cubeRenderer->currentCubeSide,touches[i].phase);
                        
                    } 
                    else 
                    {
                        previewCube->setPos(10000 , -10000,-10000);
                    } 
                }
                else  if (currentState<20)
                {
                    
                    camera->checkTouch(touches[i]);
                    
                }

            
            
            
            }
        
        
        
        
        }
    }
    
    
    
    
    
    
    
   /* 
    for(int i =0;i<touches.size();i++ )
    {
       
        if(touches[i].phase ==NP_TOUCH_STOP)
        {
            
            if(touches[i].target)
            {
                npTouchEvent t;
                t.name  =TOUCH_UP;
                t.target = touches[i].target;
                touches[i].target->dispatchEvent(t );
                if(t.target->isTouching(touches[i]))
                {
                    npTouchEvent ti;
                    ti.name  =TOUCH_UP_INSIDE;
                    ti.target = touches[i].target;
                    touches[i].target->dispatchEvent(ti );
                    
                }
                
                
            }else
            {
                if (currentState<10)
                {
                    
                    if(cubeRenderer->getPoint(touches[i].x,touches[i ].y))
                    {
                        cubeHandler->touchedCube(cubeRenderer->currentCubeIndex,cubeRenderer->currentCubeSide,touches[i].phase);
                        
                    } else 
                    {
                     previewCube->setPos(10000 , -10000,-10000);
                    }
                }
            }
        }
        else{
            
            if( !interfaceHandler->checkTouch(touches[i]))
            {
                if(touches[i].target ==NULL){
                if (currentState<10)
                {
                    if(cubeRenderer->getPoint(touches[i].x,touches[i ].y))
                    {
                        cubeHandler->touchedCube(cubeRenderer->currentCubeIndex,cubeRenderer->currentCubeSide,touches[i].phase);
                    
                    } else 
                    {
                        previewCube->setPos(10000 , -10000,-10000);
                    } 
                }
                else  if (currentState<20){
               
                    camera->checkTouch(touches[i]);
                              
                }}
            }
              
        }
    }
    */
    
};

//landscape ==1   portrait ==0
void MainCubeBuilder::setOrientation(int orientation)
{
    if (currentorientation ==orientation)return;
    
    currentorientation =orientation;
    model->renderHit =true;
    
    cubeRenderer->setOrientation(currentorientation);
    flatRenderer->setOrientation(currentorientation);
    interfaceHandler->setOrientation(currentorientation);
   
    backGround->setOrientation(currentorientation);
    cout << "set";
    

}
void MainCubeBuilder::becameActive(npEvent *e)
{
    
     model->isDirty =true;

}
