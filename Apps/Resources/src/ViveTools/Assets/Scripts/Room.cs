using UnityEngine;
using System.Collections;

public class Room : MonoBehaviour
{
    public Renderer LightCube;

    void Start()
    {

    }
    
    void Update()
    {
        DynamicGI.UpdateMaterials(LightCube);
    }
}
