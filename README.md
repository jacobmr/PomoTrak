# PomoTrak

A simple and effective Pomodoro timer application for macOS.

## About This Fork

This project is a fork of [mattato](https://github.com/mreider/mattato) by [mreider](https://github.com/mreider), with the following improvements:
- Modernized codebase with Swift concurrency (async/await)
- Fixed memory leaks and concurrency issues
- Improved build system and packaging
- Added DMG creation and notarization

### Key Differences from Original
- Uses Swift Concurrency for better performance and reliability
- Simplified build process with shell scripts
- Added proper code signing and notarization for macOS
- Updated documentation and project structure

## Download

[Download Latest Version](https://github.com/jacobmr/PomoTrak/releases/latest/download/PomoTrak.dmg)

## Features

- Clean, distraction-free interface
- Customizable work/break intervals
- Session tracking
- Built with SwiftUI

## Requirements

- macOS 12.0 or later
- Apple Silicon or Intel processor

## Building from Source

```bash
# Clone the repository
git clone https://github.com/jacobmr/PomoTrak.git
cd PomoTrak/PomoTrak

# Build the app
./build-app.sh
```

## License

MIT
