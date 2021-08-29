using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class VRPhysicallyTrackedObject : MonoBehaviour
{
    const float P = 0.1f;

    public float Strength;
    public float TorqueStrength;
    private Rigidbody rigid;

    private SteamVR_Utils.RigidTransform pose;
    public bool isValid = false;
    public SteamVR_TrackedObject.EIndex index;

    void Start()
    {
        rigid = GetComponent<Rigidbody>();
    }

    private void OnNewPoses(params object[] args)
    {
        if (index == SteamVR_TrackedObject.EIndex.None)
            return;

        var i = (int)index;

        isValid = false;
        var poses = (Valve.VR.TrackedDevicePose_t[])args[0];
        if (poses.Length <= i)
            return;

        if (!poses[i].bDeviceIsConnected)
            return;

        if (!poses[i].bPoseIsValid)
            return;

        isValid = true;

        pose = new SteamVR_Utils.RigidTransform(poses[i].mDeviceToAbsoluteTracking);
    }

    void FixedUpdate()
    {
        Vector3 posDiff = pose.pos - rigid.position;
        Vector3 rotDiff = pose.rot.eulerAngles - rigid.rotation.eulerAngles;
        Vector3 force = posDiff * P;
        if (force.magnitude > Strength)
        {
            force = force.normalized * Strength;
        }
        Vector3 torque = rotDiff * P;
        if (torque.magnitude > TorqueStrength)
        {
            torque = torque.normalized * TorqueStrength;
        }

        rigid.AddForce(posDiff);
        rigid.AddTorque(torque);
    }

    void OnEnable()
    {
        var render = SteamVR_Render.instance;
        if (render == null)
        {
            enabled = false;
            return;
        }

        SteamVR_Utils.Event.Listen("new_poses", OnNewPoses);
    }

    void OnDisable()
    {
        SteamVR_Utils.Event.Remove("new_poses", OnNewPoses);
        isValid = false;
    }

    public void SetDeviceIndex(int index)
    {
        if (System.Enum.IsDefined(typeof(SteamVR_TrackedObject.EIndex), index))
            this.index = (SteamVR_TrackedObject.EIndex)index;
    }
}
