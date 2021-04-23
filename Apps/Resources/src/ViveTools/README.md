#Vive Tools
Vive Tools is a suite of utilities for the HTC Vive, specifically in games that allow the player to move in ways other than walking.
DISCLAIMER: I don't own a Vive so I can only test this stuff when someone on the Stevens Game Development Club Executive Board will hang out with me while I use the club's. I will put out release tags when I can test the stability of this stuff.

[Gains Controller](#gains controller)
[Physics Controller](#Physics controller)
[VRButton](#vrbutton)

##Gains Controller
The Gains Controller scales the players movement dynamically to resync the real world play area with the virtual play area, or allow the player to walk around a virtual space that is larger than the real world space.

The Gains Controller uses "Gains Zones" that are placed throughout the virtual world. Gains Zones are representations of what the real world space should be mapping to. When a Gains Controller enters a Gains Zone, it will begin using gains to align itself with the Gains Zone and do any stretching it needs to do for Gains Zones that are larger that the world space.

One thing of note is that trigger colliders will only work if one of the objects taking part in the collision has a rigidbody. Make sure to add one to the Gains Zone or the player, this can be set to kinematic.

##Physics Controller
The Physics Controller is a rigidbody based character controller for the Vive. This allows the player to interact with the physics engine and lets the physics engine interact with the player. It is recommended that this is used in conjunction with the Gains Controller because the moving of the player with physics will naturally desync the virtual world and the real world.
Note: The hands and such do not move based on physics, so it will kind of be fine if you have colliders on them, but pushing on things will not work how you might expect. I am working on a controller that will not just copy the real world positions but rather try to match it using forces making interactions with things more natural.

##VRButton
The VRButton is a simple script that triggers a Unity message on a handler GameObject when collided with. This uses the OnTriggerEnter action so the button requires a trigger collider.