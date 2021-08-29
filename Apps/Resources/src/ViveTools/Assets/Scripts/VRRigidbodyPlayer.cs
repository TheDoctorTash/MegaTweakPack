using UnityEngine;
using System.Collections;

public class VRRigidbodyPlayer : MonoBehaviour
{
    const float grav = 9.81f;
    const float boxWidth=0.12f;
    enum GravStateEnum
    {
        FallingReal,
        FallingVirtual,
        OnGround
    }
    public static float Height;

    public float HeadSize=0.1f;

    Transform head;
    GameObject bodyGO;
    Transform bodyTrans;
    Vector3 playerLastPosition;
    Vector3 lastBodyCenter;
    CapsuleCollider body;

    Rigidbody rigid;
    GravStateEnum gravState = GravStateEnum.OnGround;

    void Start()
    {
    	head=transform.Find("Camera (eye)");
    	bodyGO=new GameObject();
    	bodyTrans=bodyGO.GetComponent<Transform>();
    	bodyTrans.parent=transform;
        body = bodyGO.gameObject.AddComponent<CapsuleCollider>();
        body.radius=0.2f;
        rigid = GetComponent<Rigidbody>();
    }

    void Update ()
	{
		bodyTrans.position = head.position;
		float bodyHeight = head.localPosition.y;
		bool tooTall = bodyHeight > Height + 0.15f;
		if (tooTall) {
			bodyHeight = Height;
		}
		body.height = bodyHeight+HeadSize;
		Vector3 bodyCenter = body.center;
		bodyCenter.y = -bodyHeight / 2+HeadSize/2;
		body.center = bodyCenter;

		//Debug.Log ("grav state: " + gravState);

		switch (gravState) {
		case GravStateEnum.FallingReal:
			{
				if (!tooTall) {
					//player is no longer falling
					gravState = GravStateEnum.FallingVirtual;
					rigid.useGravity = true;
					//add player real world velocity to the rigidbody
					rigid.velocity += (head.position + bodyCenter - playerLastPosition+lastBodyCenter) / Time.deltaTime;
				} else {
					playerLastPosition = head.position;
					lastBodyCenter=bodyCenter;
					//Player is currently falling in the real world
					rigid.useGravity = false;//Turns off virtual gravity because real world acceleration is moving the player
					//rigid.AddForce(Vector3.up * grav, ForceMode.Acceleration);
					RaycastHit hit;
					if (Physics.BoxCast (new Vector3 (head.position.x, head.position.y - bodyHeight+0.2f , head.position.z), new Vector3 (boxWidth, 0.1f, boxWidth), Vector3.down, out hit,Quaternion.identity, 0.2f)) {

						//}
						//if (Physics. (new Vector3 (head.position.x, head.position.y - bodyHeight, head.position.z), Vector3.down, out hit, 0.4f)) {
						rigid.useGravity = true;
						gravState = GravStateEnum.OnGround;
					}
				}
			}
			break;
		case GravStateEnum.FallingVirtual:
			{

				//Debug.DrawRay(new Vector3 (head.position.x, head.position.y - bodyHeight+0.1f, head.position.z),Vector3.down*0.4f,Color.blue);
				RaycastHit hit;
				if (Physics.BoxCast (new Vector3 (head.position.x, head.position.y - bodyHeight+0.2f , head.position.z), new Vector3 (boxWidth, 0.1f, boxWidth), Vector3.down, out hit,Quaternion.identity, 0.2f)) {

					//}
					//if (Physics. (new Vector3 (head.position.x, head.position.y - bodyHeight, head.position.z), Vector3.down, out hit, 0.4f)) {
					gravState = GravStateEnum.OnGround;
				}
			}
			break;
		case GravStateEnum.OnGround:
			{
				if (tooTall) {
					gravState = GravStateEnum.FallingReal;
				} else {
					RaycastHit hit;
					if (!Physics.BoxCast (new Vector3 (head.position.x, head.position.y - bodyHeight+0.2f, head.position.z), new Vector3 (boxWidth, 0.1f, boxWidth), Vector3.down, out hit,Quaternion.identity, 0.2f)) {
						//if (!Physics.Raycast (new Vector3 (head.position.x, head.position.y - bodyHeight+0.1f, head.position.z), Vector3.down, out hit, 0.4f)) {
						gravState = GravStateEnum.FallingVirtual;
					}
					//else
					//{
					//	Vector3 direction=head.position-playerLastPosition;
						//direction.y=0.2f;
					//	rigid.AddForce(direction.normalized*1f);
					//}
				}
			}
                break;
            default:
                break;
        }

    }

    public Gain FilterGains(Gain gain)
    {
        switch (gravState)
        {
            //case GravStateEnum.FallingReal:
            //    break;
            case GravStateEnum.FallingVirtual:
                return new Gain(0,0,0,0);
                break;
            default:
                return gain;
                break;
        }
    }
}
