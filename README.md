# 3D-Fighting-Camera
Script and Mathematical operations involved on how this Camera works

![p1_p2](https://github.com/user-attachments/assets/74f5d77c-dfb1-42a2-9e0b-5a3ed8d6f849) 


# Mathematical explanation is on progress
You can still download de Godot project to see the source code and to play around
Movement of PJ Cylinders are not programmed yet, move the PJ1 or PJ2 node directly


# Explanation
## Naive approach
We can just create a 2D vector between PJ1 and PJ2 (Vector_PJ), wich sense goes from PJ1 to PJ2; and then creata a perpendicular 2D Vector (Perp_Vector_PJ) that intersectes in the mid point (MidPoint_PJ) and take the angle between these vectors to assign it to the camera rotation and from there set the camera position.
Problem is, Perp_Vector_PJ has fixed sense, given by Vector_PJ, causing the camera to always having the PJ1 on the Left Side and the PJ2 on the Right Side, even on * *cross-ups* *, * *cross-unders* * or just punctual collision issues where PJs pass each other trough.
**image**  

## New approach
Create a new 2D Vector parallel to Perp_Vector_PJ (Cam_Virtual_Direction), it  represents the previous Perp_Vector_PJ; this new vector will be used to create another 2D Vector (Scalar_Proj) wich is the result of projecting Cam_Virtual_Direction onto Perp_Vector_PJ.
**image**  

**Cam_Virtual_Direction** is a vector that represents the direction of the Perp_Vector_PJ, but not its sense is not used.  
**Scalar_Proj** is a vector that has the direction and sense needed to paralelize Cam_Virtual_Direction Vector, no matter the sense of the Perp_Vector_PJ Vector.
**image**  

With these vectors we can take the angular difference (Ang_Diff) between Cam_Virtual_Direction and Scalar_Proj, and subtract the result to the Camera Y Rotation.
**image**  

> ### Consideration
> Code wise, Ang_Diff is subtract to a Virtual float variable called Cam_YTarget_rot wich stores the rotation in radians that the Camera must follow.  
> From here we can construct a 3D Vector (Cam_Virtual_Rot) that stores the 3-Axis Rotations that the camera must follow, and another 3D Vector (Cam_Virtual_Pos) that calcualates and store the position of the camera according to the Cam_Virtual_Rot.  
>
>## Asigning Rotation
>New wit our camera rotated in the correct angle we can set the position in the space.  
>**Cam_Virtual_Rot.x: ** desired_topdown_degree  
>**Cam_Virtual_Rot.y: ** Cam_YTarget_rot  
>**Cam_Virtual_Rot.z: ** desired_tilt_degreee  
>
>### Asigning Position
>New wit our camera rotated in the correct angle we can set the position in the space.  
>**Cam_Virtual_Pos.x: ** sin(Cam_Virtual_Rot.y) * desired_distance_from_midpoint) + MidPoint_PJ.x  
>**Cam_Virtual_Pos.y: ** desired_height  
>**Cam_Virtual_Pos.z: ** cos(Cam_Virtual_Rot.y) * desired_distance_from_midpoint) + MidPoint_PJ.z
>
>We can apply this values as they are, or we can interpolate them, like in the Godot project 


