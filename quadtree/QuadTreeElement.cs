using Godot;
using Godot.Collections;
using System;

[GlobalClass]

public partial class QuadTreeElement : RefCounted
{
    public QuadTreeElement topLeft;
    public QuadTreeElement topRight;
    public QuadTreeElement bottomLeft;
    public QuadTreeElement bottomRight;

    public float gravityStrength;
    public Vector2 centerOfGravity;

    public RigidBody2D bodyElement;

    public Rect2 bounds;

    public bool branched = false;

    public bool special = false;

    public void branch(Array<QuadTreeElement> elements) {
        if (branched) {
            GD.Print("Branch attempt on an element that's already branched (this shouldn't happen)");
            return;
        }

        topLeft = new QuadTreeElement();
        topRight = new QuadTreeElement();
        bottomLeft = new QuadTreeElement();
        bottomRight = new QuadTreeElement();

        topLeft.bounds = new Rect2(bounds.Position, bounds.Size / 2.0F);
        topRight.bounds = new Rect2(bounds.Position + new Vector2(bounds.Size.X / 2.0F, 0), bounds.Size / 2.0F);
        bottomLeft.bounds = new Rect2(bounds.Position + new Vector2(0, bounds.Size.Y / 2.0F), bounds.Size / 2.0F);
        bottomRight.bounds = new Rect2(bounds.Position + bounds.Size / 2.0F, bounds.Size / 2.0F);

        elements.Add(topLeft);
        elements.Add(topRight);
        elements.Add(bottomLeft);
        elements.Add(bottomRight);

        branched = true;
    }

    public void placeBody(RigidBody2D body) {
        if (topLeft.bounds.HasPoint(body.Position)) {
            topLeft.bodyElement = body;
        }
        else if (topRight.bounds.HasPoint(body.Position)) {
            topRight.bodyElement = body;
        }
        else if (bottomLeft.bounds.HasPoint(body.Position)) {
            bottomLeft.bodyElement = body;
        }
        else if (bottomRight.bounds.HasPoint(body.Position)) {
            bottomRight.bodyElement = body;
        }
    }

    public void calculateCOG() {
        if (!branched)
        {
            if (IsInstanceValid(bodyElement))
            {
                float gravity = (float)this.bodyElement.Get("gravity_strength").AsDouble();
                centerOfGravity = bodyElement.Position;
                gravityStrength = gravity;
            }
            else
            {
                centerOfGravity = new Vector2(0, 0);
                gravityStrength = 0;
            }
        }
        else
        {
            Vector2 comSum = topLeft.centerOfGravity * topLeft.gravityStrength + topRight.centerOfGravity * topRight.gravityStrength + bottomLeft.centerOfGravity * bottomLeft.gravityStrength + bottomRight.centerOfGravity * bottomRight.gravityStrength;
            float gravitySum = topLeft.gravityStrength + topRight.gravityStrength + bottomLeft.gravityStrength + bottomRight.gravityStrength;
            centerOfGravity = comSum / gravitySum;
            gravityStrength = gravitySum;
        }
    }
}
