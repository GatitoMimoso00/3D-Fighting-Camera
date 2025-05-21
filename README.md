# 3D-Fighting-Camera
Camera that supports 3 axis of momevement like Tekken or Soul Calibur games.  
Forwards and backwards, Side Step in and out; and Cross-up/under handling.  
Script and Mathematical operations involved on how this Camera works.  
![Thumbnail](https://github.com/user-attachments/assets/ed217a80-8165-4f11-8107-8da59ca6281f)  

Keyboard movement implemented!  
Yellow Cylinder controls = W,A,S,D (Cross-UP = WA or WD)  
Blue Cylinder controls = I,J,K,L (Cross-UP = IJ or IL)  

# Mathematical explanation
## Naive approach
We can just create a 2D vector between PJ1 and PJ2 (*Vector_PJ*), wich sense goes from PJ1 to PJ2; and then creata a perpendicular 2D Vector (*Perp_Vector_PJ*) that intersectes in the mid point (*MidPoint_PJ*) and take the angle between these vectors to assign it to the camera rotation and from there set the camera position.
Problem is, *Perp_Vector_PJ* has fixed sense, given by *Vector_PJ*, causing the camera to always having the PJ1 on the Left Side and the PJ2 on the Right Side, even on *cross-ups*, *cross-unders* or just punctual collision issues where PJs pass each other trough.  
![1_naive](https://github.com/user-attachments/assets/3855e2a2-e2e2-4042-8530-026cc80412bb)  
![2_naive](https://github.com/user-attachments/assets/c73a01c0-5a6c-4b92-855c-599bf40571d3)  
![3_naive](https://github.com/user-attachments/assets/45c27b17-562c-40f6-93e9-93cf25e38503)  
We can see that, no matter what, PJ1 is always clockwise acording to *Perp_Vector_PJ*.  

## New approach
Create a new 2D Vector parallel to Perp_Vector_PJ (*Cam_Virtual_Direction*), it  represents the previous *Perp_Vector_PJ*; this new vector will be used to create another 2D Vector (*Scalar_Proj*) wich is the result of projecting *Cam_Virtual_Direction* onto *Perp_Vector_PJ*.  

> **Cam_Virtual_Direction:** is a vector that represents the direction of the *Perp_Vector_PJ*, but not its sense is not used.  
> **Scalar_Proj:** is a vector that has the direction of *Perp_Vector_PJ* and the sense of *Cam_Virtual_Direction*.  

![Per_same](https://github.com/user-attachments/assets/48dc4954-64ad-4915-8645-61f310d2664d)  
![Per_opposite](https://github.com/user-attachments/assets/97c06c48-9457-4a1a-82fc-b3a5896c1ce6)  
Even with a sudden exchange of PJs positions, the *Scalar_Proj* remains perpendicular to the PJs and retains its sense.  

With these vectors we can take the angular difference (*Ang_Diff*) between *Cam_Virtual_Direction* and *Scalar_Proj*, and subtract the result to the Camera Y Rotation.  
![Angluar_Difference](https://github.com/user-attachments/assets/46e897da-8ce4-45d9-8a0f-e28a8501da3d)  

> ## Consideration
> Code wise, *Ang_Diff* is subtract to a Virtual float variable called *Cam_YTarget_rot* wich stores the rotation in radians that the Camera must follow.  
> From here we can construct a 3D Vector (*Cam_Virtual_Rot*) that stores the 3-Axis Rotations that the camera must follow, and another 3D Vector (*Cam_Virtual_Pos*) that calcualates and store the position of the camera according to the *Cam_Virtual_Rot*.  
>
> ## Asigning Rotation
>New wit our camera rotated in the correct angle we can set the position in the space.  
> **Cam_Virtual_Rot.x:** desired_topdown_degree  
> **Cam_Virtual_Rot.y:** *Cam_YTarget_rot*  
> **Cam_Virtual_Rot.z:** desired_tilt_degreee  
>
> ### Asigning Position
>New wit our camera rotated in the correct angle we can set the position in the space.  
> **Cam_Virtual_Pos.x:** sin(*Cam_Virtual_Rot.y*) * desired_distance_from_midpoint) + *MidPoint_PJ.x*  
> **Cam_Virtual_Pos.y:** desired_height  
> **Cam_Virtual_Pos.z:** cos(*Cam_Virtual_Rot.y*) * desired_distance_from_midpoint) + *MidPoint_PJ.z*  
>
>We can apply this values as they are, or we can interpolate them, like in the Godot project

# PJs side determination
We can use cross product to determinate on wich side of the camera are the PJs.  
Even when here we are using 3D Vectors, their Y Component is omited, because the Y position of PJs is irrelevant to determinate on wich side ther are on.  

First we need:  
> **CamtoCenter_vector:** 3D Vector that goes from *Cam_Virtual_Pos* to *MidPoint_PJ* (Y component is set to 0.0), this is our vector reference.  
> **PJ1Cam_vector:** 3D Vector that goes from *Cam_Virtual_Pos* to *PJ1_Pos* (Y component is set to 0.0).  

Then we apply Cross Product:  
> **PJ1_crossed = CamtoCenter_vector x PJ1Cam_vector**  

This will give us a 3D Vector with only the Y Component, if this component is positive or 0 then PJ1 is on the Left Side of the Camera, and by discard, PJ2 is on the Right Side of the Camera.  

![Producto_Vectorial_según_el_angulo_entre_vectores](https://github.com/user-attachments/assets/bdbd65e2-e3b3-4f25-acea-673e7524cbf5)

>This image illustrate how it works.  
>We can take Vector A like *CamtoCenter_vector* and Vector B like *PJ1Cam_vector*, their Y component are 0.  
>The Vector AxB is the cross product *PJ1_crossed*, its Horizontal Components (X and Z) are 0.  
