# Contributing to Face Detected

Thank you for your interest in contributing to Face Detected! This document provides guidelines and information for contributors.

## 🤝 Ways to Contribute

- 🐛 **Bug Reports**: Report bugs and issues
- 💡 **Feature Requests**: Suggest new features
- 📝 **Documentation**: Improve documentation
- 🛠️ **Code Contributions**: Submit pull requests
- 🧪 **Testing**: Help test the package
- 🌍 **Translations**: Help with internationalization

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.9.2)
- Git
- Android Studio / VS Code
- Physical device or emulator with camera

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/AliJassib/face_detected_pub_dev.git
   cd face_detected_pub_dev
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   cd example
   flutter pub get
   ```

3. **Run the example**
   ```bash
   cd example
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

5. **Run analysis**
   ```bash
   flutter analyze
   ```

## 📝 Development Guidelines

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` to format code
- Run `flutter analyze` to check for issues
- Add comments for complex logic
- Use meaningful variable and function names

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(camera): add support for custom camera resolution
fix(detection): improve face detection accuracy in low light
docs(readme): update installation instructions
style(widgets): format code according to dart style guide
```

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

### Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Add tests for new functionality
   - Update documentation if needed

3. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   cd example && flutter run
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use a clear title and description
   - Reference any related issues
   - Include screenshots for UI changes
   - Ensure CI passes

## 🐛 Bug Reports

When reporting bugs, please include:

### Required Information

- **Flutter version**: `flutter --version`
- **Package version**: Version of face_detected
- **Platform**: Android/iOS version
- **Device**: Physical device or emulator details

### Bug Report Template

```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Screenshots**
If applicable, add screenshots.

**Environment**
- Flutter version: 
- Package version: 
- Platform: 
- Device: 

**Additional Context**
Any other context about the problem.
```

## 💡 Feature Requests

### Feature Request Template

```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Use Case**
Why would this feature be useful?

**Proposed Solution**
How do you think this should be implemented?

**Alternatives Considered**
Any alternative solutions you've considered.

**Additional Context**
Any other context about the feature request.
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/face_detection_test.dart
```

### Writing Tests

- Add unit tests for new functionality
- Test edge cases and error conditions
- Use descriptive test names
- Group related tests

**Example:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:face_detected/face_detected.dart';

void main() {
  group('FaceVerificationConfig', () {
    test('should create config with default values', () {
      const config = FaceVerificationConfig();
      
      expect(config.timeoutPerStep, 5);
      expect(config.smileThreshold, 0.7);
      expect(config.saveImages, true);
    });

    test('should create config with custom values', () {
      const config = FaceVerificationConfig(
        timeoutPerStep: 10,
        smileThreshold: 0.8,
      );
      
      expect(config.timeoutPerStep, 10);
      expect(config.smileThreshold, 0.8);
    });
  });
}
```

## 📚 Documentation

### Documentation Standards

- Use clear, concise language
- Include code examples
- Add screenshots for UI features
- Keep documentation up to date
- Use proper markdown formatting

### Documentation Structure

```
docs/
├── api.md              # API documentation
├── getting-started.md  # Getting started guide
├── examples.md         # Usage examples
├── troubleshooting.md  # Common issues
└── contributing.md     # This file
```

## 🔧 Project Structure

```
lib/
├── face_detected.dart                 # Main export file
├── src/
│   ├── controllers/                   # State management
│   ├── models/                        # Data models
│   ├── services/                      # Business logic
│   ├── utils/                         # Utility functions
│   ├── widgets/                       # UI components
│   └── face_verification.dart         # Main API
├── android/                           # Android platform code
├── ios/                              # iOS platform code
├── example/                          # Example app
├── test/                             # Unit tests
└── doc/                              # Documentation
```

## 🏷️ Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- `MAJOR`: Breaking changes
- `MINOR`: New features (backward compatible)
- `PATCH`: Bug fixes (backward compatible)

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run all tests
- [ ] Update documentation
- [ ] Create release tag
- [ ] Publish to pub.dev

## 📞 Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General discussions
- **Email**: support@alijassib.com

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## 🙏 Recognition

Contributors will be recognized in:

- `CONTRIBUTORS.md` file
- Release notes
- Package documentation

Thank you for contributing to Face Detected! 🎉
