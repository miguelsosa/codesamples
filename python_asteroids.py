### Sample from python script - implementation of asteroids program.

### NOTE: This will not work as-is.  This contains only code that I
### wrote. Several of the classes missing were provided by the
### professors for this class.

### NOTE2: This code is from an introductory python class - as such
### the class professors made a conscious decision to use global
### variables to simplify some of the development.  I would normally
### avoid using global variables as much as possible.

import simplegui
import math
import random

# globals for user interface
WIDTH = 800
HEIGHT = 600
score = 0
lives = 3
time = 0.5
started = False

# CONSTANTS
DEBUG = True
MAX_ROCKS = 12

# helper functions to handle transformations

def print_if_debug(text):
    if DEBUG:
        print(text)

# process_sprite_group helper:
#  Take a set and a canvas and call the update and draw methods for each
#  sprite in the group. 
def process_sprite_group(canvas, sprite_set):
    expired_set = set()
    for s in sprite_set:
        s.draw(canvas)
        s.update()
        if s.expired():
            expired_set.add(s)
    if len(expired_set) > 0:
        sprite_set.difference_update(expired_set)

def distance(p1, p2):
    return math.sqrt((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2)

def would_collide(o1_pos, o1_radius, o2_pos, o2_radius):
    return (distance(o1_pos, o2_pos) < (o1_radius + o2_radius))

'''
group_collide helper function. 

 Take a set group and an a sprite other_object and check for collisions
 If there is a collision, remove this from the group. 
 Return the number of collisions. 
'''
def group_collide(a_set, an_object):
    collision_set = set()
    for item in a_set:
        if item.collide(an_object):
            collision_set.add(item)
            '''
            Bonus

            In group_collide, if there is a collision, create a new explosion (an
            instance of the Sprite class)and add it to the explosion_group. Make
            sure that each explosion plays the explosion sound.
            '''
            an_explosion = Sprite(item.pos, item.vel, item.angle, item.angle_vel, explosion_image, explosion_info, explosion_sound)
            print_if_debug("Adding an explosion at: " + str(item.pos) + str(an_explosion))
            explosion_group.add(an_explosion)
            if isinstance(an_object, Ship):
                an_explosion2 = Sprite(an_object.pos, an_object.vel, an_object.angle, an_object.angle_vel, explosion_image, explosion_info, explosion_sound)
                explosion_group.add(an_explosion2)

    if len(collision_set) > 0:
        a_set.difference_update(collision_set)
    return len(collision_set)

'''
helper function group_group_collide 

 Takes two groups of objects as input. 
 Iterate through the elements of a copy of the first group using a for-loop and then
 call group_collide with each of these elements on the second group.

 return the number of elements in the first group that collide with the second group as well as delete these
 elements in the first group.
'''

def group_group_collide(a_set, b_set):
    collision_set = set()
    for i in a_set:
        collisions = group_collide(b_set, i)
        if collisions > 0:
            collision_set.add(i)
    num_collisions = len(collision_set)
    if num_collisions > 0:
        a_set.difference_update(collision_set)
    return num_collisions

def angle_to_vector(ang):
    return [math.cos(ang), math.sin(ang)]

def dist(p, q):
    return math.sqrt((p[0] - q[0]) ** 2 + (p[1] - q[1]) ** 2)


# Ship class
class Ship:
    def __init__(self, pos, vel, angle, image, info):
        self.pos = [pos[0], pos[1]]
        self.vel = [vel[0], vel[1]]
        self.thrust = False
        self.angle = angle
        self.angle_vel = 0
        self.image = image
        self.image_center = info.get_center()
        self.image_size = info.get_size()
        self.radius = info.get_radius()

    def draw(self, canvas):
        if self.thrust:
            canvas.draw_image(self.image, [self.image_center[0] + self.image_size[0], self.image_center[1]] , self.image_size,
                              self.pos, self.image_size, self.angle)
        else:
            canvas.draw_image(self.image, self.image_center, self.image_size,
                              self.pos, self.image_size, self.angle)
            # canvas.draw_circle(self.pos, self.radius, 1, "White", "White")

    def update(self):
        # update angle
        self.angle += self.angle_vel
        
        # update position
        self.pos[0] = (self.pos[0] + self.vel[0]) % WIDTH
        self.pos[1] = (self.pos[1] + self.vel[1]) % HEIGHT

        # update velocity
        if self.thrust:
            acc = angle_to_vector(self.angle)
            self.vel[0] += acc[0] * .1
            self.vel[1] += acc[1] * .1
            
        self.vel[0] *= .99
        self.vel[1] *= .99

    def set_thrust(self, on):
        self.thrust = on
        if on:
            ship_thrust_sound.rewind()
            ship_thrust_sound.play()
        else:
            ship_thrust_sound.pause()
            
    def increment_angle_vel(self):
        self.angle_vel += .05
        
    def decrement_angle_vel(self):
        self.angle_vel -= .05
        
    def shoot(self):
        global missile_group
        forward = angle_to_vector(self.angle)
        missile_pos = [self.pos[0] + self.radius * forward[0], self.pos[1] + self.radius * forward[1]]
        missile_vel = [self.vel[0] + 6 * forward[0], self.vel[1] + 6 * forward[1]]
        missile_group.add(Sprite(missile_pos, missile_vel, self.angle, 0, missile_image, missile_info, missile_sound))

    def get_position(self):
        return self.pos

    def get_radius(self):
        return self.radius
    
# Sprite class
class Sprite:
    def __init__(self, pos, vel, ang, ang_vel, image, info, sound = None):
        self.pos = [pos[0],pos[1]]
        self.vel = [vel[0],vel[1]]
        self.angle = ang
        self.angle_vel = ang_vel
        self.image = image
        self.image_center = info.get_center()
        self.image_size = info.get_size()
        self.radius = info.get_radius()
        self.lifespan = info.get_lifespan()
        self.animated = info.get_animated()
        self.age = 0
        if sound:
            sound.rewind()
            sound.play()
            
    def draw(self, canvas):

        '''
        Bonus: 
        In the draw method of the Sprite class, check if self.animated is
        True. If so, then choose the correct tile in the image based on the
        age. The image is tiled horizontally. If self.animated is False, it
        should continue to draw the sprite as before.
        '''
        if self.animated:
            xpos = self.image_center[0] + (self.age*(self.image_size[0]))
            image_center = [xpos, self.image_center[0]]
        else:
            image_center = self.image_center
        canvas.draw_image(self.image, image_center, self.image_size,
                              self.pos, self.image_size, self.angle)

    def expired(self):
        return (self.age > self.lifespan)

    def update(self):
        # update angle
        self.angle += self.angle_vel
        
        # update position
        self.pos[0] = (self.pos[0] + self.vel[0]) % WIDTH
        self.pos[1] = (self.pos[1] + self.vel[1]) % HEIGHT

        # update Age
        self.age += 1

    def get_position(self):
        return self.pos

    def get_radius(self):
        return self.radius

    def collide(self, other):
        return would_collide(self.get_position(), self.get_radius(), other.get_position(), other.get_radius())
        
        
# key handlers to control ship   
def keydown(key):
    if key == simplegui.KEY_MAP['left']:
        my_ship.decrement_angle_vel()
    elif key == simplegui.KEY_MAP['right']:
        my_ship.increment_angle_vel()
    elif key == simplegui.KEY_MAP['up']:
        my_ship.set_thrust(True)
    elif key == simplegui.KEY_MAP['space']:
        my_ship.shoot()
        
def keyup(key):
    if key == simplegui.KEY_MAP['left']:
        my_ship.increment_angle_vel()
    elif key == simplegui.KEY_MAP['right']:
        my_ship.decrement_angle_vel()
    elif key == simplegui.KEY_MAP['up']:
        my_ship.set_thrust(False)
        
# mouseclick handlers that reset UI and conditions whether splash image is drawn
def click(pos):
    global started, score, lives
    center = [WIDTH / 2, HEIGHT / 2]
    size = splash_info.get_size()
    inwidth = (center[0] - size[0] / 2) < pos[0] < (center[0] + size[0] / 2)
    inheight = (center[1] - size[1] / 2) < pos[1] < (center[1] + size[1] / 2)
    if (not started) and inwidth and inheight:
        started = True
        score = 0
        lives = 3
        soundtrack.rewind()
        soundtrack.play()


def draw(canvas):
    global time, started, rock_group, missile_group, explosion_group, lives, my_ship, score, started
    
    # animate background
    time += 1
    center = debris_info.get_center()
    size = debris_info.get_size()
    wtime = (time / 8) % center[0]
    canvas.draw_image(nebula_image, nebula_info.get_center(), nebula_info.get_size(), [WIDTH / 2, HEIGHT / 2], [WIDTH, HEIGHT])
    canvas.draw_image(debris_image, [center[0] - wtime, center[1]], [size[0] - 2 * wtime, size[1]], 
                      [WIDTH / 2 + 1.25 * wtime, HEIGHT / 2], [WIDTH - 2.5 * wtime, HEIGHT])
    canvas.draw_image(debris_image, [size[0] - wtime, center[1]], [2 * wtime, size[1]], 
                      [1.25 * wtime, HEIGHT / 2], [2.5 * wtime, HEIGHT])

    # draw UI
    canvas.draw_text("Lives", [50, 50], 22, "White")
    canvas.draw_text("Score", [680, 50], 22, "White")
    canvas.draw_text(str(lives), [50, 80], 22, "White")
    canvas.draw_text(str(score), [680, 80], 22, "White")

    # draw ship and sprites
    my_ship.draw(canvas)
    process_sprite_group(canvas, rock_group)
    process_sprite_group(canvas, missile_group)
    '''
    Bonus
    In the draw handler, use process_sprite_group to process
    explosion_group.
    '''
    process_sprite_group(canvas, explosion_group)
    
    # update ship and sprites
    my_ship.update()

    # draw splash screen if not started
    if not started:
        canvas.draw_image(splash_image, splash_info.get_center(), 
                          splash_info.get_size(), [WIDTH / 2, HEIGHT / 2], 
                          splash_info.get_size())

    if len(rock_group) > 0:
        if len(missile_group) > 0:
            collisions = group_group_collide(missile_group, rock_group)
            if  collisions > 0:
                print_if_debug("Asteroid destroyed:" + str(collisions))
                score += collisions

        collisions = group_collide(rock_group, my_ship)
        if  collisions > 0:
            print_if_debug("Ship destroyed:" + str(collisions))
            lives -= 1
            if lives == 0:
                print_if_debug("Game Over")
                started = False
                # Destroy rocks
                rock_group = set()


# timer handler that spawns a rock    
def rock_spawner():
    global rock_group, started, my_ship

    if not started:
        return

    if len(rock_group) < MAX_ROCKS:
        rock_pos = [random.randrange(0, WIDTH), random.randrange(0, HEIGHT)]
        # Prevent rock from spawning on top of the ship
        if would_collide(rock_pos, asteroid_info.get_radius(), my_ship.get_position(), my_ship.get_radius()):
            print_if_debug("Skip spawn")
            return
        print_if_debug("Spawn a rock")
        vel_mul = 4
        rock_vel = [random.random() * vel_mul - vel_mul/2, random.random() * vel_mul - vel_mul/2]
        rock_avel = random.random() * .2 - .1
        a_rock = Sprite(rock_pos, rock_vel, 0, rock_avel, asteroid_image, asteroid_info)
        rock_group.add(a_rock)


# initialize stuff
frame = simplegui.create_frame("Asteroids", WIDTH, HEIGHT)

# initialize ship and two sprites
my_ship = Ship([WIDTH / 2, HEIGHT / 2], [0, 0], 0, ship_image, ship_info)
rock_group = set()
# Sprite([WIDTH / 3, HEIGHT / 3], [1, 1], 0, .1, asteroid_image, asteroid_info)
missile_group = set()
# Sprite([2 * WIDTH / 3, 2 * HEIGHT / 3], [-1,1], 0, 0, missile_image, missile_info, missile_sound)

''' 
Bonus
Create an explosion_group global variable and initialize it to an
empty set.
'''
explosion_group = set()

# register handlers
frame.set_keyup_handler(keyup)
frame.set_keydown_handler(keydown)
frame.set_mouseclick_handler(click)
frame.set_draw_handler(draw)

timer = simplegui.create_timer(1000.0, rock_spawner)

# get things rolling
timer.start()
frame.start()
