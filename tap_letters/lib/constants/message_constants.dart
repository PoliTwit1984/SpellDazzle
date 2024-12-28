class MessageConstants {
  static const List<String> waitingMessages = [
    'Waiting for letters...',
    'Ready to spell something amazing?',
    'Your next word awaits!',
    'Time to get creative!',
    'Let\'s make some words!',
    'Spell your way to victory!',
    'What will you create?',
    'Words are magic!',
    'Show us your vocabulary!',
    'The letters are coming...',
  ];

  static const List<String> hintMessages = [
    'Drag letters to rearrange them',
    'Double-tap to throw back a letter',
    'Longer words = more points!',
    'Try to use all available letters',
    'Keep an eye on the timer',
    'Look for common word patterns',
  ];

  static String getRandomWaitingMessage() {
    return waitingMessages[DateTime.now().millisecondsSinceEpoch % waitingMessages.length];
  }

  static String getRandomHint() {
    return hintMessages[DateTime.now().millisecondsSinceEpoch % hintMessages.length];
  }
}
