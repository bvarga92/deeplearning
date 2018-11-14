import sys
import numpy as np
import random
import contextlib
with contextlib.redirect_stdout(None): import pygame

FPS = 30
SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
COLOR_BACKGROUND = [255, 255, 255]
COLOR_PADDLE = [0, 0, 0]
COLOR_BALL = [255, 0, 0]
PADDLE_X = 0.985
PADDLE_WIDTH = 0.01
PADDLE_HEIGHT = 0.2
BALL_SIZE_PX = 5
ALPHA0 = 0.3
ALPHA_DECAY = False
GAMMA = 0.5
EPOCHS = 5000000
LOAD_FROM_FILE = True
DEBUG_MODE = False

Q = np.zeros([10369, 3])
epoch = 0
state_num_prev = 0
action_prev = 0

def update(state, action):
    ball_x = state[0]
    ball_y = state[1]
    velocity_x = state[2]
    velocity_y = state[3]
    paddle_y = state[4]
    reward = 0
    if action == 1:
        paddle_y -= 0.04
        if paddle_y < 0: paddle_y = 0
    elif action == 2:
        paddle_y += 0.04
        if paddle_y + PADDLE_HEIGHT > 1: paddle_y = 1 - PADDLE_HEIGHT
    ball_x += velocity_x
    ball_y += velocity_y
    if ball_x < 0:
        ball_x = -ball_x
        velocity_x = -velocity_x
    if ball_y < 0:
        ball_y = -ball_y
        velocity_y = -velocity_y
    if ball_y > 1:
        ball_y = 2 - ball_y
        velocity_y = -velocity_y
    if ball_x > 1:
        if (paddle_y < ball_y) and ((paddle_y + PADDLE_HEIGHT) > ball_y):
            ball_x = 2*PADDLE_X - ball_x
            velocity_x = -velocity_x + random.uniform(-0.01, 0.01)
            if velocity_x > -0.02:
                velocity_x = -0.02
            elif velocity_x < -0.05:
                velocity_x = -0.05
            velocity_y = -velocity_y + random.uniform(-0.01, 0.01)
            if velocity_y > 0.05:
                velocity_y = 0.05
            elif velocity_y < -0.05:
                velocity_y = -0.05
            reward = 1
        else:
            ball_x = 0.5
            ball_y = 0.5
            velocity_x = 0.02
            velocity_y = 0.01
            reward = -1
    return [ball_x, ball_y, velocity_x, velocity_y, paddle_y], reward

def calculate_action(state, reward):
    global epoch, state_num_prev, action_prev
    state_discrete = [None]*5
    # labda helyzete a jatekteren: 12*12 lehetoseg
    state_discrete[0]=np.floor(state[0]*11.999)
    state_discrete[1]=np.floor(state[1]*11.999)
    # labda x iranyu sebessege: 2 lehetoseg (kozeledik, tavolodik)
    if state[2] < 0:
        state_discrete[2] = 0
    else:
        state_discrete[2] = 1
    # labda y iranyu sebessege: 3 lehetoseg (felfele, lefele, egyenesen)
    if abs(state[3]) < 0.015:
        state_discrete[3] = 0
    elif state[3] < 0:
        state_discrete[3] = 1
    else:
        state_discrete[3] = 2
    # uto helyzete: 12 lehetoseg
    state_discrete[4]=np.floor(state[4]*11.999/(1-PADDLE_HEIGHT))
    # osszesen 12*12*2*3*12+1=10369 kulonbozo allapot (+1: amikor az elozo akcio kudarchoz vezetett)
    if reward == -1:
        state_num = 10368
    else:
        state_num = int(state_discrete[0] + 12*state_discrete[1] + 144*state_discrete[2] + 288*state_discrete[3] + 864*state_discrete[4])
    # tanulas
    if epoch < EPOCHS:
        epoch += 1
        action = np.argmax(Q[state_num,:])
        if epoch > 1:
            if DEBUG_MODE:
                print(state_num_prev, "--", action_prev, "-->" , state_num, "REWARD:", reward)
            if epoch % 10000 == 0:
                print("Training epoch", epoch)
            if ALPHA_DECAY:
                alpha = ALPHA0/(ALPHA0-1+epoch)
            else:
                alpha = ALPHA0
            Q[state_num_prev, action_prev] = (1-alpha)*Q[state_num_prev, action_prev] + alpha*(reward + GAMMA*np.max(Q[state_num,:]))
            if epoch == EPOCHS:
                np.save('Q.npy',Q)
            state_num_prev = state_num
            action_prev = action
    else:
        action = np.argmax(Q[state_num,:])
    return action

def draw(state, hit, miss, font, screen):
    screen.fill(COLOR_BACKGROUND)
    pygame.draw.rect(screen, COLOR_PADDLE, [int(SCREEN_WIDTH*PADDLE_X), int(SCREEN_HEIGHT*state[4]), int(SCREEN_WIDTH*PADDLE_WIDTH), int(SCREEN_HEIGHT*PADDLE_HEIGHT)])
    pygame.draw.circle(screen, COLOR_BALL, [int(SCREEN_WIDTH*state[0]), int(SCREEN_HEIGHT*state[1])], BALL_SIZE_PX)
    if not (hit == 0 and miss == 0):
        score = font.render("HIT: %d (%.1f%%), MISS: %d (%.1f%%)" % (hit, hit*100.0/(hit+miss), miss, miss*100.0/(hit+miss)), True, COLOR_PADDLE)
        screen.blit(score, [10, 10])
    pygame.display.update()

def main():
    global epoch, Q
    state = [0.5, 0.5, 0.02, 0.01, 0.4]
    reward = 0
    action = 0
    hit = 0
    miss = 0
    player_mode = (len(sys.argv) >= 2) # ha valamilyen parameterrel inditjuk, akkor nincs tanitas, jatszhatunk siman
    if LOAD_FROM_FILE and not player_mode:
        Q = np.load('Q.npy')
        epoch = EPOCHS
    screen = pygame.display.set_mode([SCREEN_WIDTH, SCREEN_HEIGHT])
    pygame.display.set_caption('Pong Q-Learning')
    pygame.font.init()
    font = pygame.font.SysFont('Comic Sans MS', 24)
    clock = pygame.time.Clock()
    running = True
    while running:
        for event in pygame.event.get():
            if (event.type == pygame.QUIT) or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
                running = False
            if player_mode:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_UP:
                        action = 1
                    if event.key == pygame.K_DOWN:
                        action = 2
                if event.type == pygame.KEYUP:
                    if event.key == pygame.K_UP or event.key == pygame.K_DOWN:
                        action = 0
        if not player_mode:
            action = calculate_action(state, reward)
        state, reward = update(state, action)
        if (not player_mode) and (epoch < EPOCHS):
            if DEBUG_MODE:
                draw(state, 0, 0, None, screen)
                clock.tick(0)
        else:
            if reward != 0:
                if reward > 0:
                    hit += 1
                else:
                    miss += 1
            draw(state, hit, miss, font, screen)
            clock.tick(FPS)

if __name__ == "__main__":
    main()
