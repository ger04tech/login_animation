# Animated Login with Rive 🐻

![](https://github.com/ger04tech/login_animation/blob/main/CAPTURA%20LOGIN.png)

## Project Overview 🧐
An interactive login screen featuring a Rive-animated character that responds in real-time to user input. The character provides visual feedback through eye movements, hand gestures, and emotional reactions during the login process

## ✨ Key Features
1. 🐻 Interactive Character that reacts to form interactions
2. 👀 Smart Eye Tracking - follows typing progress in email field
3. 🙈 Hand Animation - covers eyes when password is hidden
4. ✅ Real-time Validation - dynamic checklist updates as you type
5. 🎭 State Machine Control - seamless animation transitions
6. ⏳ Loading States - prevents double-tap and shows progress
7. 📋 Dynamic Checklist - visual feedback for validation rules
8. ⌨️ Debounced Input - smooth character reactions

## 🤔 What is Rive?
Rive is a powerful real-time animation platform that allows developers to create interactive vector animations. Unlike static animations, Rive animations can be controlled programmatically through state machines and input parameters.

## 🎮 State Machine Concept
A State Machine in Rive is a visual programming system that manages animation states and transitions:

1. Inputs: Boolean values, numbers, and triggers
2. States: Animation sequences (idle, checking, hands up, etc.)
3. Transitions: Rules for moving between states
4. Outputs: Animation properties controlled in real-time
## 😁In this project
- isChecking - Character looks at typing cursor
- isHandsUp - Hands cover eyes for password protection
- trigSuccess - Celebration animation for valid login
- trigFail - Disappointment animation for invalid login
- numLook - Controls eye movement based on input length


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
