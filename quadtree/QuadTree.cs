using Godot;
using Godot.Collections;
using System.Collections.Generic;

[GlobalClass]

public partial class QuadTree : QuadTreeElement
{
    public Array<QuadTreeElement> elements = new Array<QuadTreeElement>();
    public Array<RigidBody2D> bodies = new Array<RigidBody2D>();

    public Vector2 origin = Vector2.Zero;

    public void build() {
        resetTree();
        for (int i = 0; i < bodies.Count; i++) {
            int insertResult = insertBody(this, bodies[i]);

            if (insertResult == 1) //If the tree fails to insert the body
            {
                RigidBody2D current = bodies[i];
                bodies.Remove(current);
                current.Free();
                i--;
            }
        }
        updateTreeCOG();
    }


    public int insertBody(QuadTreeElement element, RigidBody2D body) {
        QuadTreeElement ce = element;
        while (true)
        {
            if (!IsInstanceValid(ce.bodyElement) && ce.branched) //Traverse down the tree
            {
                if (ce.topLeft.bounds.HasPoint(body.Position)) {
                    ce = ce.topLeft;
                }
                else if (ce.topRight.bounds.HasPoint(body.Position)) {
                    ce = ce.topRight;
                }
                else if (ce.bottomLeft.bounds.HasPoint(body.Position)) {
                    ce = ce.bottomLeft;
                }
                else if (ce.bottomRight.bounds.HasPoint(body.Position)) {
                    ce = ce.bottomRight;
                }
                else {
                    return 1;
                }
            }
            else if (!IsInstanceValid(ce.bodyElement) && !ce.branched) { //If ce is an empty leaf, place the body there.
                ce.bodyElement = body;
                return 0;
            }
            else if (IsInstanceValid(ce.bodyElement) && !ce.branched) { //If ce is a leaf with a body already in it, branch.
                ce.branch(elements);
                ce.placeBody(ce.bodyElement);
                ce.bodyElement = null;
            }
        }
    }

    public void resetTree() {
        elements.Clear();
        elements.Add(this);
        topLeft = null;
        topRight = null;
        bottomLeft = null;
        bottomRight = null;
        branched = false;
        branch(this.elements);
        //setTreeBounds();
        var boundSize = new Vector2(2000, 2000);
        bounds = new Rect2(-boundSize / 2.0F, boundSize);
    }

    public void updateTreeCOG() {
        for (int i = elements.Count - 1; i > -1; i--) {
            elements[i].calculateCOG();
        }
    }

    public float theta = 0.3F;
    public float G = 2000.0F;



    public void gravityUpdate(RigidBody2D body, QuadTreeElement element, float gravityRange) {
        Stack<QuadTreeElement> stack = new Stack<QuadTreeElement>();
        stack.Push(element);
        while (stack.Count > 0) {

            float g1 = (float)body.Get("gravity_strength").AsDouble();

            QuadTreeElement current = stack.Pop();
            if (current.gravityStrength == 0)
            {
                continue;
            }
            if (current.bodyElement == body) {
                continue;
            }

            float dist = body.Position.DistanceTo(current.centerOfGravity);
            float sd = current.bounds.Size.X / dist;
             
            if (sd >= theta)
            {
                if (current.branched)
                {
                    stack.Push(current.topLeft);
                    stack.Push(current.topRight);
                    stack.Push(current.bottomLeft);
                    stack.Push(current.bottomRight);
                }
            }
            else
            {
                if (dist <= gravityRange)
                {
                    //float force = G * ((body.F * current.mass) / (dist * dist));
                    float force = G * ((g1 * current.gravityStrength) / (dist * dist));
                    Vector2 forceVector = body.Position.DirectionTo(current.centerOfGravity) * force;
                    body.ApplyForce(forceVector);

                    ////Makes blobs stick together better
                    //if (IsInstanceValid(current.bodyElement))
                    //{
                    //    current.bodyElement.ApplyForce(-forceVector);
                    //}
                }
            }
        }
    }
}
