from subprocess import run
import unittest
from os import listdir
import yaml


class DOFTestCase(unittest.TestCase):
    def test_dof_example_element(self):
        """Validate example element against dof schema"""
        examples_dir = "src/data/examples/"
        examples_list = listdir(examples_dir)
        examples_list.sort()

        # load dof schema
        with open("dist/dof.yaml", "r") as file:
            schema_as_yaml = file.read()
        schema = yaml.safe_load(schema_as_yaml)

        for example in examples_list:
            try:
                for element_type in schema["classes"].keys():
                    if element_type in example:
                        element_type_to_be_validated = element_type
                        break
                print("validating", example, "against", element_type_to_be_validated)
                run(
                    [
                        "linkml-validate",
                        "-s",
                        "dist/dof.yaml",
                        "-C",
                        element_type_to_be_validated,
                        "".join([examples_dir, example]),
                    ]
                )
            except ValueError as e:
                errors.append(str(e))


if __name__ == "__main__":
    unittest.main()
