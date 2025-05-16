import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(description='Calculate coverage statistics')
    parser.add_argument('-s', '--sample', type=str, required=True, help='Sample name')
    parser.add_argument('-i', '--input-dir', type=str, required=True, help='Input directory')
    parser.add_argument('-o', '--output-dir', type=str, required=True, help='Output directory')
    return parser.parse_args()
