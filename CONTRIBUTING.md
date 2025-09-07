# Contributing to AlpacaPi

Thank you for your interest in contributing to AlpacaPi! This document provides guidelines and information for contributors.

## <i class="bi bi-heart"></i> **How to Contribute**

We welcome contributions from the community! Here are the main ways you can help:

### **<i class="bi bi-bug"></i> Bug Reports**
- Use the [GitHub Issues](https://github.com/your-username/AlpacaPi/issues) page
- Include detailed reproduction steps
- Provide system information (OS, hardware, driver versions)
- Attach relevant log files

### **<i class="bi bi-lightbulb"></i> Feature Requests**
- Open an issue with the "enhancement" label
- Describe the use case and expected behavior
- Consider if it aligns with the project goals

### **<i class="bi bi-code"></i> Code Contributions**
- Fork the repository
- Create a feature branch
- Make your changes
- Submit a pull request

## <i class="bi bi-list-check"></i> **Development Guidelines**

### **Code Style**
- Follow the existing C++ coding standards
- Use C++17 features appropriately
- Maintain consistent formatting
- Add comments for complex logic

### **Commit Messages**
Use clear, descriptive commit messages:
```
feat: Add support for new camera model
fix: Resolve memory leak in driver initialization
docs: Update installation instructions
refactor: Reorganize driver directory structure
```

### **Testing**
- Test your changes on target hardware when possible
- Ensure existing functionality still works
- Add tests for new features
- Update documentation as needed

## <i class="bi bi-diagram-3"></i> **Project Structure**

Understanding the project structure helps with contributions:

```
AlpacaPi/
├── src/                    # Core source code
│   ├── core/              # Main AlpacaPi server
│   ├── net/               # Network protocols
│   ├── proto/             # Protocol implementations
│   └── util/              # Utilities and helpers
├── drivers/               # Device drivers (organized by manufacturer)
├── pi-gen/                # Custom Raspberry Pi OS images
├── examples/              # Example applications
├── scripts/               # Build and installation scripts
└── docs/                  # Documentation
```

## <i class="bi bi-gear"></i> **Development Setup**

### **Prerequisites**
- CMake 3.10+
- C++17 compatible compiler
- Git
- (Optional) Docker for pi-gen builds

### **Build Instructions**
```bash
# Clone the repository
git clone https://github.com/your-username/AlpacaPi.git
cd AlpacaPi

# Create build directory
mkdir build && cd build

# Configure and build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j4

# Run tests
make test
```

## <i class="bi bi-puzzle"></i> **Driver Development**

### **Adding New Drivers**
1. Create driver directory in `drivers/[manufacturer]/`
2. Implement the driver interface
3. Add to CMake build system
4. Update documentation
5. Test with target hardware

### **Driver Structure**
```cpp
// Example driver header
class CameraDriver_NewModel : public AlpacaDriver {
public:
    CameraDriver_NewModel();
    ~CameraDriver_NewModel();
    
    // Implement required methods
    bool Connect() override;
    bool Disconnect() override;
    // ... other methods
};
```

## <i class="bi bi-file-text"></i> **Documentation**

### **Code Documentation**
- Use Doxygen-style comments for public APIs
- Document complex algorithms
- Include usage examples

### **User Documentation**
- Update README.md for major changes
- Add driver-specific documentation
- Update installation instructions

## <i class="bi bi-shield-check"></i> **Quality Standards**

### **Code Quality**
- No memory leaks
- Proper error handling
- Resource cleanup
- Thread safety where applicable

### **Testing Requirements**
- Unit tests for new features
- Integration tests for drivers
- Manual testing on target hardware
- Performance testing for critical paths

## <i class="bi bi-git"></i> **Pull Request Process**

### **Before Submitting**
1. Ensure your code compiles without warnings
2. Run all existing tests
3. Update documentation if needed
4. Test on target hardware if possible

### **Pull Request Template**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Hardware testing completed (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## <i class="bi bi-people"></i> **Community Guidelines**

### **Code of Conduct**
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow the golden rule

### **Communication**
- Use clear, professional language
- Provide context for suggestions
- Ask questions when unsure
- Share knowledge and experience

## <i class="bi bi-question-circle"></i> **Getting Help**

### **Questions and Support**
- Check existing issues and discussions
- Ask questions in GitHub Discussions
- Contact maintainers for sensitive issues
- Join the community forum (if available)

### **Resources**
- [Main Documentation](https://msproul.github.io/AlpacaPi/)
- [API Reference](docs/alpacapi.pdf)
- [Driver Documentation](docs/drivers.html)

## <i class="bi bi-award"></i> **Recognition**

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation
- Community acknowledgments

## <i class="bi bi-file-earmark-text"></i> **License**

By contributing to AlpacaPi, you agree that your contributions will be licensed under the same terms as the project. See [LICENSE.md](LICENSE.md) for details.

---

## <i class="bi bi-heart"></i> **Thank You**

Thank you for contributing to AlpacaPi! Your efforts help make astronomy more accessible and enjoyable for everyone.

---

*For questions about contributing, please open an issue or contact the maintainers.*
