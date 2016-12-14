program OpenGLApp;

uses
  Windows,
  Messages,
  Math,
  OpenGL;

const
  WND_TITLE = ':D';
  FPS_TIMER = 1;                     // Timer to calculate FPS
  FPS_INTERVAL = 1000;               // Calculate FPS every 1000 ms

  azul: Array[0..3] of GLfloat = (0,0,1,1);

var
  h_Wnd  : HWND;                     // Global window handle
  h_DC   : HDC;                      // Global device context
  h_RC   : HGLRC;                    // OpenGL rendering context
  keys : Array[0..255] of Boolean;   // Holds keystrokes
  FPSCount : Integer = 0;            // Counter for FPS
  ElapsedTime : Integer;             // Elapsed time between frames

  DrawShaded : boolean = true;

  light_ambient : array[0..3] of GLfloat = ( 0.3, 0.3, 0.3, 1.0 );
  light_diffuse : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
  light_specular : array[0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
  light_position : array[0..3] of GLfloat = ( 5.0, 40.0, -4.0, 2.0 );

  deathzone: array [0..3,-5..5,-5..5] of Real;
  positionX,positionZ,altura:Double;
  spin:Real;
{$R *.RES}

procedure Display();
var x,z,lz,lx:Double;
    tempX,tempZ:Double;
    j,k:integer;
    flagX,flagZ,aux1,aux2:boolean;
begin
x:= sin(DegToRad(spin));
z:= cos(DegToRad(spin));
lx:= sin(DegToRad(spin+90));
lz:= cos(DegToRad(spin+90));
  tempX:=positionX;
  tempZ:=positionZ;
  if keys[83] then begin
	  tempX:=tempX-0.02*x;
    tempZ:=tempZ+0.02*z;
  end;
  if keys[87] then begin
    tempX:=tempX+0.02*x;
    tempZ:=tempZ-0.02*z;
  end;
  if keys[65] then begin
    tempX:=tempX-0.02*(lx);
    tempZ:=tempZ+0.02*(lz);
	end;
  if keys[68] then begin
    tempX:=tempX+0.02*(lx);
    tempZ:=tempZ-0.02*(lz);
	end;
  //  Algoritmo deteccion de colisiones
  flagX:=true;
  flagZ:=true;
  for j :=  -5 to 5 do
    for k :=  -5 to 5 do
      begin
      aux1:= true;
      aux2:= true;
      if (tempX < deathzone[0,j,k]) or (tempX > deathzone[1,j,k]) then
        aux1:=false; //positionX:=tempX;
      if (tempX > deathzone[0,j,k]) or (tempX < deathzone[1,j,k]) then
        if (positionZ < deathzone[2,j,k]) or (positionZ > deathzone[3,j,k]) then
          aux2:=false;
      if aux1 and aux2 then flagX:= false;
      
      aux1:= true;
      aux2:= true;          
      if (tempZ < deathzone[2,j,k]) or (tempZ > deathzone[3,j,k]) then
        aux1:=false; //positionZ:=tempZ;
      if (tempZ > deathzone[2,j,k]) or (tempZ < deathzone[3,j,k]) then
        if (positionX < deathzone[0,j,k]) or (positionX > deathzone[1,j,k]) then
          aux2:=false;
      if aux1 and aux2 then flagZ:= false;
      end;
  if flagX then positionX:=tempX;
  if flagZ then positionZ:=tempZ;
  // Fin deteccion
  if keys[40] then begin //down
    altura:=altura+0.01;
	end;
  if keys[38] then begin //up
    altura:=altura-0.01;
	end;
  if keys[39] then  //right
    begin
      spin:=spin+0.05; //Rotamos el angulo de observación de la escena...
      if spin > 360.0 then
        spin := spin - 360.0;
    end;
  if keys[37] then  //left
    begin
      spin:=spin-0.05; //Rotamos el angulo de observación de la escena...
      if spin < 360.0 then
        spin := spin + 360.0;
    end;
end;

procedure drawCube;
begin
    glColor3f(1.0, 0.0, 0.0);
    glBegin(GL_QUADS);       //cara frontal
    glNormal3f(0,0,1);
    glVertex3f(-1.0, -1.0,  1.0);
    glVertex3f( 1.0, -1.0,  1.0);
    glVertex3f( 1.0,  1.0,  1.0);
    glVertex3f(-1.0,  1.0,  1.0);
    glEnd();

    glColor3f(0.0, 1.0, 0.0);
    glBegin(GL_QUADS);       //cara trasera
    glNormal3f(0,0,-1);
    glVertex3f( 1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0,  1.0, -1.0);
    glVertex3f( 1.0,  1.0, -1.0);
    glEnd();

    glColor3f(0.0, 0.0, 1.0);
    glBegin(GL_QUADS);       //cara lateral izq
    glNormal3f(-1,0,0);
    glVertex3f(-1.0,-1.0, -1.0);
    glVertex3f(-1.0,-1.0,  1.0);
    glVertex3f(-1.0, 1.0,  1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glEnd();

    glColor3f(1.0, 1.0, 0.0);
    glBegin(GL_QUADS);       //cara lateral dcha
    glNormal3f(1,0,0);
    glVertex3f(1.0, -1.0,  1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0,  1.0, -1.0);
    glVertex3f(1.0,  1.0,  1.0);
    glEnd();

    glColor3f(0.0, 1.0, 1.0);
    glBegin(GL_QUADS);       //cara arriba
    glNormal3f(0,1,0);
    glVertex3f(-1.0, 1.0,  1.0);
    glVertex3f( 1.0, 1.0,  1.0);
    glVertex3f( 1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glEnd();

    glColor3f(1.0, 0.0, 1.0);
    glBegin(GL_QUADS);       //cara abajo
    glNormal3f(0,-1,0);
    glVertex3f( 1.0,-1.0, -1.0);
    glVertex3f( 1.0,-1.0,  1.0);
    glVertex3f(-1.0,-1.0,  1.0);
    glVertex3f(-1.0,-1.0, -1.0);
    glEnd();
end;

{------------------------------------------------------------------}
{  Function to convert int to string. (No sysutils = smaller EXE)  }
{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;

procedure Normalize(out v : array of GLFloat);
var d : GLfloat;
begin
  d := sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
   if (d = 0.0) then
   begin
      // Error
      exit;
   end;
   v[0] := v[0] / d;
   v[1] := v[1] / d;
   v[2] := v[2] / d;

end;

procedure NormCrossProd(v1, v2 : array of GLfloat;out vout : array of GLFLoat);
begin
   vout[0] := v1[1]*v2[2] - v1[2]*v2[1];
   vout[1] := v1[2]*v2[0] - v1[0]*v2[2];
   vout[2] := v1[0]*v2[1] - v1[1]*v2[0];
   Normalize(vout);
end;

{------------------------------------------------------------------}
{  Deteccion de Colisiones                                         }
{------------------------------------------------------------------}
procedure initialize;
var
  i,j,k: Integer;
begin
  spin:=0;
  positionX:=0;
  positionZ:=2.3;
  for j := -5 to 5 do
    for k := -5 to 5 do
      for i := 0 to 1 do
      begin
        deathzone[i,j,k] :=   (i-0.5)*4.4+j*8;
        deathzone[i+2,j,k] := (i-0.5)*4.4+k*8;
      end;
end;

{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}
procedure glDraw();
var i, j : GLint;
    d1 : array[0..2] of GLfloat;
    d2 : array[0..2] of GLfloat;
    norm : array[0..2] of GLfloat;
begin
  glClearColor(0.0, 0.0, 0.0, 1.0); // Black Background
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear the colour and depth buffer
  glLoadIdentity();                 // Load a "clean" model matrix on the stack
  Display;
	glRotatef(spin,0,1,0);
  glTranslatef(-positionX,altura,-positionZ);
  for i := -5 to 5 do
    for j := -5 to 5 do
    begin
      glPushMatrix;
        glTranslatef(i*8,0,j*8);
        drawCube;
      glPopMatrix;
    end;

  // Flush the OpenGL Buffer
  glFlush();                        // ( Force the buffer to draw or send a network packet of commands in a networked system)

end;


{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}
procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 1.0); // Black Background
  glColor3f(1.0, 1.0, 1.0);         // Set the Polygon colour to white
  glEnable(GL_DEPTH_TEST);          // Enable Depth testing
  glDepthFunc(GL_LEQUAL);
  glShadeModel(GL_SMOOTH);            // Use smooth shading
  glHint(GL_SHADE_MODEL,GL_NICEST);   // Set the smooth shaiding to the best we can have

  // Enable Lighting ( This will be explained in a later chapter)
  glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ambient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR,@light_specular);
  glLightfv(GL_LIGHT0, GL_POSITION,@light_position);

  //glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);


end;
 

{------------------------------------------------------------------}
{  Handle window resize                                            }
{------------------------------------------------------------------}
procedure glResizeWnd(Width, Height : Integer);
begin
  if (Height = 0) then                // prevent divide by zero exception
    Height := 1;
  glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
  glLoadIdentity();                   // Reset View
end;


{------------------------------------------------------------------}
{  Processes all the keystrokes                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  if keys[75] then   // K
  begin
    DrawShaded := not DrawShaded;
    keys[75] := False;
  end;
end;


{------------------------------------------------------------------}
{  Determines the application’s response to the messages received  }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case (Msg) of
    WM_CREATE:
      begin
        // Insert stuff you want executed when the program starts
        initialize;
      end;
    WM_CLOSE:
      begin
        PostQuitMessage(0);
        Result := 0
      end;
    WM_KEYDOWN:       // Set the pressed key (wparam) to equal true so we can check if its pressed
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Set the released key (wparam) to equal false so we can check if its pressed
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_SIZE:          // Resize the window with the new width and height
      begin
        glResizeWnd(LOWORD(lParam),HIWORD(lParam));
        Result := 0;
      end;
    WM_TIMER :                     // Add code here for all timers to be used.
      begin
        if wParam = FPS_TIMER then
        begin
          FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // calculate to get per Second incase intercal is less or greater than 1 second
          SetWindowText(h_Wnd, PChar(WND_TITLE + '   [' + intToStr(FPSCount) + ' FPS]'));
          FPSCount := 0;
          Result := 0;
        end;
      end;
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
  end;
end;


{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}
procedure glKillWnd(Fullscreen : Boolean);
begin
  if Fullscreen then             // Change back to non fullscreen
  begin
    ChangeDisplaySettings(devmode(nil^), 0);
    ShowCursor(True);
  end;

  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
  if (not wglMakeCurrent(h_DC, 0)) then
    MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Attempts to delete the rendering context
  if (not wglDeleteContext(h_RC)) then
  begin
    MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_RC := 0;
  end;

  // Attemps to release the device context
  if ((h_DC > 0) and (ReleaseDC(h_Wnd, h_DC) = 0)) then
  begin
    MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_DC := 0;
  end;

  // Attempts to destroy the window
  if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then
  begin
    MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
    h_Wnd := 0;
  end;

  // Attempts to unregister the window class
  if (not UnRegisterClass('OpenGL', hInstance)) then
  begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Creates the window and attaches a OpenGL rendering context to it  }
{--------------------------------------------------------------------}
function glCreateWnd(Width, Height : Integer; Fullscreen : Boolean; PixelDepth : Integer) : Boolean;
var
  wndClass : TWndClass;         // Window class
  dwStyle : DWORD;              // Window styles
  dwExStyle : DWORD;            // Extended window styles
  dmScreenSettings : DEVMODE;   // Screen settings (fullscreen, etc...)
  PixelFormat : GLuint;         // Settings for the OpenGL rendering
  h_Instance : HINST;           // Current instance
  pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
  h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

  with wndClass do                    // Set up the window class
  begin
    style         := CS_HREDRAW or    // Redraws entire window if length changes
                     CS_VREDRAW or    // Redraws entire window if height changes
                     CS_OWNDC;        // Unique device context for the window
    lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'OpenGL';
  end;

  if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit
  end;

  // Change to fullscreen if so desired
  if Fullscreen then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Set parameters for the screen setting
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Width;                    // Window width
      dmPelsHeight := Height;                   // Window height
      dmBitsPerPel := PixelDepth;               // Window color depth
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to fullscreen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  // If we are still in fullscreen then
  if (Fullscreen) then
  begin
    dwStyle := WS_POPUP or                // Creates a popup window
               WS_CLIPCHILDREN            // Doesn't draw within child windows
               or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW;         // Top level window
    ShowCursor(False);                    // Turn of the cursor (gets in the way)
  end
  else
  begin
    dwStyle := WS_OVERLAPPEDWINDOW or     // Creates an overlapping window
               WS_CLIPCHILDREN or         // Doesn't draw within child windows
               WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW or       // Top level window
                 WS_EX_WINDOWEDGE;        // Border with a raised edge
  end;

  // Attempt to create the actual window
  h_Wnd := CreateWindowEx(dwExStyle,      // Extended window styles
                          'OpenGL',       // Class name
                          WND_TITLE,      // Window title (caption)
                          dwStyle,        // Window styles
                          0, 0,           // Window position
                          Width, Height,  // Size of window
                          0,              // No parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if h_Wnd = 0 then
  begin
    glKillWnd(Fullscreen);                // Undo all the settings we've changed
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // The version of this data structure
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                       or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
    cColorBits      := PixelDepth;           // OpenGL color depth
    cRedBits        := 0;                    // Number of red bitplanes
    cRedShift       := 0;                    // Shift count for red bitplanes
    cGreenBits      := 0;                    // Number of green bitplanes
    cGreenShift     := 0;                    // Shift count for green bitplanes
    cBlueBits       := 0;                    // Number of blue bitplanes
    cBlueShift      := 0;                    // Shift count for blue bitplanes
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                    // No accumulation buffer
    cAccumRedBits   := 0;                    // Number of red bits in a-buffer
    cAccumGreenBits := 0;                    // Number of green bits in a-buffer
    cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
    cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
    cDepthBits      := 16;                   // Specifies the depth of the depth buffer
    cStencilBits    := 0;                    // Turn off stencil buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Ignored
    bReserved       := 0;                    // Number of overlay and underlay planes
    dwLayerMask     := 0;                    // Ignored
    dwVisibleMask   := 0;                    // Transparent color of underlay plane
    dwDamageMask    := 0;                     // Ignored
  end;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Create a OpenGL rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Initializes the timer used to calculate the FPS
  SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

  // Settings to ensure that the window is the topmost window
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  // Ensure the OpenGL window is resized properly
  glResizeWnd(Width, Height);
  glInit(); // Initialise any OpenGL States and variables 

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  finished : Boolean;
  DemoStart, LastTime : DWord;
begin
  finished := False;

  // Perform application initialization:
  if not glCreateWnd(800, 600, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  DemoStart := GetTickCount();            // Get Time when demo started

  // Main message loop:
  while not finished do
  begin
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Check if there is a message for this window
    begin
      if (msg.message = WM_QUIT) then     // If WM_QUIT message received then we are done
        finished := True
      else
      begin                               // Else translate and dispatch the message to this window
  	TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      Inc(FPSCount);                      // Increment FPS Counter

      LastTime :=ElapsedTime;
      ElapsedTime :=GetTickCount() - DemoStart;     // Calculate Elapsed Time
      ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

      glDraw();                           // Draw the scene ( Call any OpenGL Rendering code in this function)
      SwapBuffers(h_DC);                  // Display the scene

      if (keys[VK_ESCAPE]) then           // If user pressed ESC then set finised TRUE
        finished := True
      else
        ProcessKeys;                      // Check for any other key Pressed
    end;
  end;
  glKillWnd(FALSE);
  Result := msg.wParam;
end;


begin
  WinMain( hInstance, hPrevInst, CmdLine, CmdShow );
end.
