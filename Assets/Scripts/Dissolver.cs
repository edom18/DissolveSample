using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Renderer))]
public class Dissolver : MonoBehaviour {

    Material m_Material;
    YieldInstruction m_Instruction = new WaitForEndOfFrame();

	void Start () {
        m_Material = GetComponent<Renderer>().material;
        StartCoroutine("Animate");
	}

    IEnumerator Animate() {
        float time = 0;
        float duration = 5f;
        int dir = 1;

        while (true) {
            yield return m_Instruction;

            time += Time.deltaTime * dir;
            var t = time / duration;

            if (t > 1f) {
                dir = -1;
            }
            else if (t < 0) {
                dir = 1;
            }

            m_Material.SetFloat("_CutOff", t);
        }
    }
}
